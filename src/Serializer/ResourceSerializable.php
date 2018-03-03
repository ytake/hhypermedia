<?hh // strict

namespace Ytake\HHhal\Serializer;

use Ytake\HHhal\HalResource;

interface ResourceSerializable {

  public function render(HalResource $resource): array<mixed, mixed>;
}
