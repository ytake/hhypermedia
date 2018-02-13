<?hh // strict

use PHPUnit\Framework\TestCase;
use Ytake\HHhal\Link;

final class LinkTest extends TestCase {

  public function testShouldBeLink(): void {
    $link = new Link(
      ImmVector{ "self" },
      "/root"
    );
    $this->assertInstanceOf(Link::class, $link);
    $this->assertSame([], $link->getAttributes()->toArray());
    $this->assertSame(["self"], $link->getRels()->toArray());
  }
}
