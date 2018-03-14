<?hh // strict

namespace Ytake\HHhal\Serializer;

use HH\Lib\Dict;
use Ytake\HHhal\HalResource;

class JsonSerializer implements ResourceSerializable {

  protected function serialize(
    HalResource $resource,
    array<mixed, mixed> $embedded = []
  ): array<mixed, mixed> {
    $links = [];
    $next = [];
    if ($resource->getLinks()->count()) {
      foreach($resource->getLinks() as $l => $r) {
        foreach($r->getResource() as $lr) {
          $links[$l] = [
            Property::HREF => $lr->getHref(),
          ];
          $links[$l] = array_merge($links[$l], $lr->getAttributes());
          if ($lr->isTemplated()) {
            $links[$l][Property::TEMPLATED] = true;
          }
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
    return json_encode($resources);
  }
}
