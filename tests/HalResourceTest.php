<?hh //strict

use Ytake\HHhal\{HalResource, Link, LinkResource};
use PHPUnit\Framework\TestCase;

class HalResourceTest extends TestCase {

  public function testShouldBeHalResourceObject(): void {
    $link = new Link(
      'self',
      new ImmVector([new LinkResource('/tests', shape('type' => 'application/vnd.collection+json'))]),
    );
    $resource = new HalResource(new Map([
      'id' => 123456789
    ]));
    $resource->withLink($link);
    $ar = $resource->getLinks()->toArray();
    $this->assertArrayHasKey('self', $ar);
    $this->assertSame('self', $ar['self']->getRel());
  }

  public function testShouldBeReturnEmbedded(): void {
    $link = new Link(
      'self',
      new ImmVector([new LinkResource('/tests')]),
    );
    $resource = new HalResource(new Map([
      'id' => 123456789
    ]));
    $resource->withLink($link);
    $hal = new HalResource();
    $hal->withEmbedded('tests', $resource);
    $this->assertInstanceOf(HalResource::class, $hal);
  }
}
