<?hh // strict

namespace Ytake\HHhal;

type LinkAttributes = shape(
  ?'type' => string,
  ?'deprecation' => string,
  ?'name' => string,
  ?'profile' => string,
  ?'title' => string,
  ?'hreflang' => string
);

class LinkResource {

  public function __construct(
    protected string $href,
    protected LinkAttributes $attributes = shape(),
    protected bool $templated = false
  ) {}

  public function getHref(): string {
    return $this->href;
  }

  public function getAttributes(): LinkAttributes {
    return $this->attributes;
  }

  public function isTemplated(): bool {
    return $this->templated;
  }
}
