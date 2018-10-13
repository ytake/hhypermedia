<?hh //strict

use type Ytake\HHhal\{HalResource, Link, LinkResource};
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class HalResourceTest extends HackTest {

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
    expect($ar)->toContainKey('self');
    expect($ar['self']->getRel())->toBeSame('self');
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
    expect($hal)->toBeInstanceOf(HalResource::class);
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
    expect($hal->getLinks()->toArray())->toNotBeSame(0);
    expect($hal->getResource()->toArray())->toNotBeSame(0);
    $v = $hal->getEmbedded()->get('tests');
    expect($v)->toNotBeSame(0);
    $linkResource = $v?->get(0)?->getLinks()?->get('self');
    expect($linkResource?->getResource()?->toArray())->toNotBeSame(4);
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
    expect(\count($root->getLinks()->toArray()))->toBeSame(0);
    expect(\count($root->getResource()->toArray()))->toBeSame(0);
    $v = $root->getEmbedded()->get('tests');
    expect(\count($v?->toArray()))->toBeSame(2);
    /* UNSAFE_EXPR */ $r = $v[0]->getResource()->toArray();
    /* UNSAFE_EXPR */ expect($r)->toContainKey('id');
    /* UNSAFE_EXPR */ expect($r)->toContainKey('title');
    /* UNSAFE_EXPR */ expect($r['id'])->toBeSame(123456789);
    /* UNSAFE_EXPR */ expect($r['title'])->toBeSame(9876543210);
    /* UNSAFE_EXPR */ $r = $v[1]->getResource()->toArray();
    /* UNSAFE_EXPR */ expect($r)->toContainKey('id');
    /* UNSAFE_EXPR */ expect($r)->toContainKey('title');
    /* UNSAFE_EXPR */ expect($r['id'])->toBeSame(1);
    /* UNSAFE_EXPR */ expect($r['title'])->toBeSame('merge emmbedded resource');
  }
}
