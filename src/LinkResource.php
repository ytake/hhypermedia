<?hh // strict

namespace Ytake\HHhal;

type LinkAttributes = shape(
  ?'templated' => bool,
  ?'type' => string,
);

class LinkResource {

  public function __construct(
    protected string $href,
    protected ImmMap<string, mixed> $immAttributes = ImmMap{},
    protected bool $templated = false
  ) {}

  public function getHref(): string {
    return $this->href;
  }

  public function getAttributes(): ImmMap<string, mixed> {
    return $this->immAttributes;
  }

  public function isTemplated(): bool {
    return $this->templated;
  }
}
