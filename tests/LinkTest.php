<?hh // strict

use Ytake\HHhal\{Link, LinkResource};
use PHPUnit\Framework\TestCase;

class LinkTest extends TestCase {

  public function testShouldBeLinkObjects(): void {
    $link = new Link(
      'self',
      new ImmVector([new LinkResource('/tests')]),
    );
    $this->assertInstanceOf(Link::class, $link);
    $this->assertSame($link->getRel(), 'self');
  }
}
