<?hh // strict

namespace Ytake\HHhal;

use Ytake\HHhal\Serializer\ResourceSerializable;

class Serializer {

  public function __construct(
    protected ResourceSerializable $serializer,
    protected HalResource $hal
  ) {}

  public function serialize(): string {
    return $this->serializer->render($this->toArray());
  }

  <<__Memoize>>
  public function toArray(): array<mixed, mixed> {
    return $this->serializer->toArray($this->hal);
  }
}
