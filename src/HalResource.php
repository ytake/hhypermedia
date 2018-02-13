<?hh // strict

namespace Ytake\HHhal;

class HalResource {
  
  protected Map<string, Link> $linkMap = Map{};

  public function __construct(
    protected string $uri, 
    protected Map<string, mixed> $map = Map{}
  ) {}

  public function withLink(Link $link): this {
    foreach($link->getRels()->toArray() as $rel) {
      $this->linkMap->add(
        Pair{$rel, $link}
      );
    }
    return $this;
  }
}
