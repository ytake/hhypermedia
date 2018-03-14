<?hh // strict

namespace Ytake\HHhal\Serializer;

use Ytake\HHhal\HalResource;

enum Property: string as string {
  TEMPLATED = 'templated';
  LINKS = '_links';
  EMBEDDED = '_embedded';
  HREF = 'href';
}

interface ResourceSerializable {

  public function render(array<mixed, mixed> $resources = []): string;

  public function toArray(HalResource $resource): array<mixed, mixed>;
}
