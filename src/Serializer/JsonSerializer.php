<?hh // strict

namespace Ytake\HHhal\Serializer;

use HH\Lib\Dict;
use Ytake\HHhal\HalResource;

class JsonSerializer implements ResourceSerializable {

  protected array<string, array<mixed, mixed>> $embedded = [];

  protected array<mixed, mixed> $resource = [];

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
            'href' => $lr->getHref(),
          ];
          $links[$l] = array_merge($links[$l], $lr->getAttributes()->toArray());
          if ($lr->isTemplated()) {
            $links[$l]['templated'] = true;
          }
        }
      }
    }
    $embedded = array_merge($embedded, $resource->getResource()->toArray());
    if (count($links)) {
      $embedded['_links'] = $links;
    }
    if ($resource->getEmbedded()->count()) {
      foreach($resource->getEmbedded() as $k => $row) {
        if($row->count()) {
          $next[$k] = $this->resource;
          foreach($row as $vec) {
            $embedded['_embedded'][$k][] = $this->serialize($vec, $next[$k]);
          }
        }
      }
    }
    return $embedded;
  }

  public function render(HalResource $resource, array<mixed, mixed> $embedded = []): array<mixed, mixed> {
    return $this->serialize($resource, $embedded);
  }
}
