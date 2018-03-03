<?hh // strict

namespace Ytake\HHhal;

class HalResource {

  protected Map<string, Link> $links = Map{};

  protected Map<string, Vector<HalResource>> $embedded = Map{};

  public function __construct(
    protected Map<string, mixed> $resources = Map{}
  ) {}

  public function withResource(string $key, mixed $value): this {
    $this->resources->add(Pair{$key, $value});
    return $this;
  }

  public function withLink(Link $link): this {
    $this->links->add(Pair{$link->getRel(), $link});
    return $this;
  }

  public function withEmbedded(
    string $embbeddedName,
    HalResource $resource
  ): this {
    if ($this->embedded->containsKey($embbeddedName)) {
      $r = $this->embedded->get($embbeddedName);
      if(!is_null($r)) {
        $r->add($resource);
      }
    }
    $this->embedded->add(
      Pair{$embbeddedName, Vector{$resource}}
    );
    return $this;
  }

  public function getLinks(): Map<string, Link> {
    return $this->links;
  }

  public function getEmbedded(): Map<string, Vector<HalResource>> {
    return $this->embedded;
  }

  public function getResource(): Map<string, mixed> {
    return $this->resources;
  }
}
