/**
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * This software consists of voluntary contributions made by many individuals
 * and is licensed under the MIT license.
 *
 * Copyright (c) 2018-2019 Yuuki Takezawa
 *
 */
namespace Ytake\Hhypermedia\Serializer;

use type Ytake\Hhypermedia\Link;
use type Ytake\Hhypermedia\Curie;
use type Ytake\Hhypermedia\Property;
use type Ytake\Hhypermedia\ResourceSerializer;
use type Ytake\Hhypermedia\HalResource;
use type Ytake\Hhypermedia\RootResource;
use namespace HH\Lib\{C, Dict, Vec};
use function json_encode;

class HalJsonSerializer implements ResourceSerializer {

  protected function resolveSingleLink(
    Link $link
  ): dict<arraykey, mixed> {
    $links = dict[];
    foreach($link->getResource() as $lr) {
      $links = dict[
        Property::HREF => $lr->getHref(),
      ];
      if ($lr->isTemplated()) {
        $links = Dict\merge($links, dict[Property::TEMPLATED => true]);
      }
      $links = Dict\merge($links, Shapes::toDict($lr->getAttributes()));
    }
    return $links;
  }

  protected function resolveMultipleLinks(
    Link $link
  ): vec<mixed> {
    $v = vec[];
    $links = vec[];
    foreach($link->getResource() as $lr) {
      $linkResource = dict[Property::HREF => $lr->getHref()];
      if ($lr->isTemplated()) {
        $linkResource = Dict\merge($linkResource, dict[Property::TEMPLATED => true]);
      }
      $v[] = $linkResource;
      $links = Vec\concat($v, Shapes::toDict($lr->getAttributes()));
    }
    return $links;
  }

  /**
   * for curies
   */
  private function resolveCuires(Curie $link): vec<dict<arraykey, mixed>> {
    $links = vec[];
    foreach($link->getResource() as $lr) {
      $links[] = Dict\merge(dict[
        Property::HREF => $lr->getHref(),
        Property::TEMPLATED => $lr->isTemplated(),
      ], Shapes::toDict($lr->getAttributes()));
    }
    return $links;
  }

  protected function resolveLinks(
    RootResource $resource
  ): dict<string, mixed> {
    $links = dict[];
    if (C\count($resource->getLinks())) {
      foreach($resource->getLinks() as $namedLink => $linkResource) {
        if($linkResource is Curie) {
          $links[$namedLink] = $this->resolveCuires($linkResource);
          continue;
        }
        if(C\count($linkResource->getResource()) === 1) {
          $links[$namedLink] = $this->resolveSingleLink($linkResource);
        }
        if(C\count($linkResource->getResource()) > 1) {
          $links[$namedLink] = $this->resolveMultipleLinks($linkResource);
        }
      }
    }
    return $links;
  }

  protected function mergeElement(
    dict<string, mixed> $links,
    dict<arraykey, mixed> $embedded
  ): dict<arraykey, mixed> {
    if (C\count($links)) {
      $embedded = Dict\merge($embedded, dict[Property::LINKS => $links]);
    }
    return $embedded;
  }

  protected function resolveEmbedded(
    RootResource $resource,
    dict<arraykey, mixed> $embedded
  ): dict<arraykey, mixed> {
    $dict = vec[];
    if (C\count($resource->getEmbedded())) {
      $element = dict[];
      foreach($resource->getEmbedded() as $k => $row) {
        $element[$k] = dict[];
        $vec = vec[];
        if(C\count($row)) {
          foreach($row as $vecResource) {
            $vec[] = $this->serialize($vecResource);
          }
          if(C\count($vec)) {
            $element = Dict\merge($element, dict[$k => $vec]);
            $embedded = Dict\merge(
              $embedded,
              dict[Property::EMBEDDED => Dict\merge($element, dict[$k => $vec])]
            );
          }
        }
      }
    }
    return $embedded;
  }

  protected function serialize(
    RootResource $resource,
    dict<arraykey, mixed> $embedded = dict[]
  ): dict<arraykey, mixed> {
    $resource as HalResource;
    return $this->resolveEmbedded(
      $resource, 
      $this->mergeElement(
        $this->resolveLinks($resource),
        Dict\merge($embedded, $resource->getResource())
      )
    );
  }

  public function render(
    RootResource $resource
  ): string {
    return json_encode($this->toDict($resource));
  }

  public function toDict(
    RootResource $resource
  ):  dict<arraykey, mixed> {
    return $this->serialize($resource);
  }
}
