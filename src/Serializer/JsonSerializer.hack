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
namespace Ytake\HHhal\Serializer;

use type Ytake\HHhal\Link;
use type Ytake\HHhal\Curie;
use type Ytake\HHhal\HalResource;
use namespace HH\Lib\{C, Dict, Vec};
use function json_encode;

class JsonSerializer implements ResourceSerializable {

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
  protected function resolveCuires(Curie $link): vec<dict<arraykey, mixed>> {
    $links = vec[];
    foreach($link->getResource() as $lr) {
      $links[] = Dict\merge(dict[
        Property::HREF => $lr->getHref(),
        Property::TEMPLATED => $lr->isTemplated(),
      ], Shapes::toDict($lr->getAttributes()));
    }
    return $links;
  }

  protected function serialize(
    HalResource $resource,
    dict<arraykey, mixed> $embedded = dict[]
  ): dict<arraykey, mixed> {
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
    $embedded = Dict\merge($embedded, $resource->getResource());
    if (C\count($links)) {
      $embedded = Dict\merge($embedded, dict[Property::LINKS => $links]);
    }
    $dict = vec[];
    if (C\count($resource->getEmbedded())) {
      $element = dict[];
      foreach($resource->getEmbedded() as $k => $row) {
        $element[$k] = dict[];
        $vec = vec[];
        if(C\count($row)) {
          foreach($row as $halResource) {
            $vec[] = $this->serialize($halResource);
          }
          if(C\count($vec)) {
            $element = Dict\merge($element, dict[$k => $vec]);
            $embedded = Dict\merge(
              $embedded,
              dict[
                Property::EMBEDDED => Dict\merge(
                  $element,
                  dict[
                    $k => $vec
                  ]
                )
              ]
            );
          }
        }
      }
    }
    return $embedded;
  }

  public function toDict(
    HalResource $resource
  ): dict<arraykey, mixed> {
    return $this->serialize($resource);
  }

  public function render(
    dict<arraykey, mixed> $resources = dict[]
  ): string {
    return json_encode($resources);
  }
}
