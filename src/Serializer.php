<?hh // strict

namespace Ytake\HHhal;

use Ytake\HHhal\Serializer\ResourceSerializable;

class Serializer {

  public function __construct(
    protected ResourceSerializable $serializer,
    protected HalResource $hal
  ) {}

  public function serialize(): string {
    return json_encode($this->rawArray());
  }

  <<__Memoize>>
  public function rawArray(): array<mixed, mixed> {
    return $this->serializer->render($this->hal);
  }
}
