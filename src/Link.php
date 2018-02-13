<?hh // strict

namespace Ytake\HHhal;

class Link {
  
  public function __construct(
    protected ImmVector<string> $rels,
    protected string $href,
    protected ImmMap<string, mixed> $immAttributes = ImmMap{},
    protected bool $templated = false
  ) {}
  
  public function getRels(): ImmVector<string> {
    return $this->rels;
  }

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
