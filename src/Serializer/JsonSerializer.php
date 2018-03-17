<?hh // strict

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
 * Copyright (c) 2018 Yuuki Takezawa
 *
 */
namespace Ytake\HHhal\Serializer;

use Ytake\HHhal\Link;
use Ytake\HHhal\Curie;
use Ytake\HHhal\HalResource;

class JsonSerializer implements ResourceSerializable {

  protected function resolveSingleLink(Link $link): array<mixed, mixed> {
    $links = [];
    foreach($link->getResource() as $lr) {
      $links = [
        Property::HREF => $lr->getHref(),
      ];
      if ($lr->isTemplated()) {
        $links[Property::TEMPLATED] = true;
      }
      $links = array_merge($links, $lr->getAttributes());
    }
    return $links;
  }

  protected function resolveMltipleLinks(Link $link): array<mixed, mixed> {
    $links = [];
    $i = 0;
    foreach($link->getResource() as $lr) {
      $links[$i] = [
        Property::HREF => $lr->getHref(),
      ];
      if ($lr->isTemplated()) {
        $links[$i][Property::TEMPLATED] = true;
      }
      $links = array_merge($links, $lr->getAttributes());
      $i++;
    }
    return $links;
  }

  /**
   * for curies
   */
  protected function resolveCuires(Curie $link): array<mixed, mixed> {
    $links = [];
    foreach($link->getResource() as $lr) {
      $links[] = array_merge([
        Property::HREF => $lr->getHref(),
        Property::TEMPLATED => $lr->isTemplated(),
      ], $lr->getAttributes());
    }
    return $links;
  }

  protected function serialize(
    HalResource $resource,
    array<mixed, mixed> $embedded = []
  ): array<mixed, mixed> {
    $links = [];
    $next = [];
    if ($resource->getLinks()->count()) {
      foreach($resource->getLinks() as $namedLink => $linkResource) {
        if($linkResource instanceof Curie) {
          $links[$namedLink] = $this->resolveCuires($linkResource);
          continue;
        }
        if($linkResource->getResource()->count() === 1) {
          $links[$namedLink] = $this->resolveSingleLink($linkResource);
        }
        if($linkResource->getResource()->count() > 1) {
          $links[$namedLink] = $this->resolveMltipleLinks($linkResource);
        }
      }
    }
    $embedded = array_merge($embedded, $resource->getResource()->toArray());
    if (count($links)) {
      $embedded[Property::LINKS] = $links;
    }
    if ($resource->getEmbedded()->count()) {
      foreach($resource->getEmbedded() as $k => $row) {
        if($row->count()) {
          foreach($row as $vec) {
            $embedded[Property::EMBEDDED][$k][] = $this->serialize($vec);
          }
        }
      }
    }
    return $embedded;
  }

  public function toArray(HalResource $resource): array<mixed, mixed> {
    return $this->serialize($resource);
  }

  public function render(array<mixed, mixed> $resources = []): string {
    if (count($resources) === 0) {
      $resources = new \stdClass();
    }
    return json_encode($resources);
  }
}
