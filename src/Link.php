<?hh // strict

namespace Ytake\HHhal;

class Link {

  public function __construct(
    protected string $rel,
    protected ImmVector<LinkResource> $link
  ) {}

  public function getRel(): string {
    return $this->rel;
  }

  public function getResource(): ImmVector<LinkResource> {
    return $this->link;
  }
}
