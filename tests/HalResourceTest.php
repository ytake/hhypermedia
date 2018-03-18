<?hh //strict

use Ytake\HHhal\{HalResource, Link, LinkResource};
use PHPUnit\Framework\TestCase;

class HalResourceTest extends TestCase {

  public function testShouldBeHalResourceObject(): void {
    $link = new Link(
      'self',
      new Vector([new LinkResource('/tests', shape('type' => 'application/vnd.collection+json'))]),
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
      new Vector([new LinkResource('/tests')]),
    );
    $resource = new HalResource(new Map([
      'id' => 123456789
    ]));
    $resource->withLink($link);
    $hal = new HalResource();
    $hal->withEmbedded('tests', Vector{$resource});
    $this->assertInstanceOf(HalResource::class, $hal);
  }

  public function testShouldBeReturnMergeLink(): void {
    $link = new Link(
      'self',
      new Vector([
        new LinkResource('/tests'),
        new LinkResource('/examples')
      ]),
    );
    $resource = new HalResource(new Map([
      'id' => 123456789
    ]));
    $resource->withLink($link);
    $resource->withLink($link);
    $resource->withLink(new Link(
      'self2',
      new Vector([
        new LinkResource('/tests'),
        new LinkResource('/examples')
      ]),
    ));
    $hal = new HalResource();
    $hal->withEmbedded('tests', Vector{$resource});
    $this->assertCount(0, $hal->getLinks()->toArray());
    $this->assertCount(0, $hal->getResource()->toArray());
    $v = $hal->getEmbedded()->get('tests');
    $this->assertNotCount(0, $v);
    /* UNSAFE_EXPR */ $linkResource = $v->get(0)->getLinks()->get('self');
    /* UNSAFE_EXPR */ $this->assertCount(4 ,$linkResource->getResource()->toArray());
  }

  public function testShouldBeReturnMergeEmbedded(): void {
    $root = new HalResource();
    $link = new Link('self',
      new Vector([
        new LinkResource('/tests')
      ]),
    );
    $resource = new HalResource(new Map([
      'id' => 123456789,
      'title' => 9876543210
    ]));
    $resource->withLink($link);
    $root->withEmbedded('tests', Vector{
      $resource,
      new HalResource(new Map([
        'id' => 1,
        'title' => 'merge emmbedded resource'
      ]))
    });
    $this->assertCount(0, $root->getLinks()->toArray());
    $this->assertCount(0, $root->getResource()->toArray());
    $v = $root->getEmbedded()->get('tests');
    $this->assertCount(2, $v?->toArray());
    /* UNSAFE_EXPR */ $r = $v[0]->getResource()->toArray();
    /* UNSAFE_EXPR */ $this->assertArrayHasKey('id', $r);
    /* UNSAFE_EXPR */ $this->assertArrayHasKey('title', $r);
    /* UNSAFE_EXPR */ $this->assertSame(123456789, $r['id']);
    /* UNSAFE_EXPR */ $this->assertSame(9876543210, $r['title']);
    /* UNSAFE_EXPR */ $r = $v[1]->getResource()->toArray();
    /* UNSAFE_EXPR */ $this->assertArrayHasKey('id', $r);
    /* UNSAFE_EXPR */ $this->assertArrayHasKey('title', $r);
    /* UNSAFE_EXPR */ $this->assertSame(1, $r['id']);
    /* UNSAFE_EXPR */ $this->assertSame('merge emmbedded resource', $r['title']);
  }
}
