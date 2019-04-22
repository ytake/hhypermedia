use type Ytake\Hhypermedia\{HalResource, Link, LinkResource, ResourceObject};
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class HalResourceTest extends HackTest {

  public function testShouldBeHalResourceObject(): void {
    $link = new Link(
      'self',
      vec[new LinkResource('/tests', shape('type' => 'application/vnd.collection+json'))],
    );
    $ro = new ResourceObject();
    $new = $ro->withLink($link);
    $resource = new HalResource($new, dict[
      'id' => 123456789
    ]);
    $ar = $resource->getLinks();
    expect($ar)->toContainKey('self');
    expect($ar['self']->getLinkRelation())->toBeSame('self');
  }

  public function testShouldBeReturnEmbedded(): void {
    $link = new Link(
      'self',
      vec[new LinkResource('/tests')],
    );
    $ro = new ResourceObject();
    $new = $ro->withLink($link);
    $resource = new HalResource($new ,dict[
      'id' => 123456789
    ]);
    $ro = new ResourceObject();
    $new = $ro->withEmbedded('tests', vec[$resource]);
    $hal = new HalResource($new);
    expect($hal)->toBeInstanceOf(HalResource::class);
  }

  public function testShouldBeReturnMergeLink(): void {
    $link = new Link(
      'self',
      vec[
        new LinkResource('/tests'),
        new LinkResource('/examples')
      ],
    );
    $ro = new ResourceObject();
    $new = $ro->withLink($link)
    |> $$->withLink($link)
    |> $$->withLink(new Link(
      'self2',
      vec[
        new LinkResource('/tests'),
        new LinkResource('/examples')
      ],
    ));
    $resource = new HalResource($new, dict[
      'id' => 123456789
    ]);
    $ero = new ResourceObject();
    $enew = $ero->withEmbedded('tests', vec[$resource]);
    $hal = new HalResource($enew);
    expect($hal->getLinks())->toNotBeSame(0);
    expect($hal->getResource())->toNotBeSame(0);
    $v = $hal->getEmbedded()['tests'];
    expect($v)->toNotBeSame(0);
    $linkResource = $v[0]->getLinks()['self'];
    expect($linkResource->getResource())->toNotBeSame(4);
  }

  public function testShouldBeReturnMergeEmbedded(): void {
    $link = new Link('self',
      vec[
        new LinkResource('/tests')
      ],
    );
    $ro = new ResourceObject();
    $new = $ro->withLink($link);

    $rootRo = new ResourceObject();
    $resource = new HalResource(new ResourceObject(), dict[
      'id' => 123456789,
      'title' => 9876543210
    ]);
    $rootNew = $rootRo->withEmbedded('tests', vec[
      $resource,
      new HalResource($new, dict[
        'id' => 1,
        'title' => 'merge emmbedded resource'
      ])
    ]);
    $root = new HalResource($rootNew);
    expect(\count($root->getLinks()))->toBeSame(0);
    expect(\count($root->getResource()))->toBeSame(0);
    $v = $root->getEmbedded()['tests'];
    expect(\count($v))->toBeSame(2);
    $r = $v[0]->getResource();
    expect($r)->toContainKey('id');
    expect($r)->toContainKey('title');
    expect($r['id'])->toBeSame(123456789);
    expect($r['title'])->toBeSame(9876543210);
    $r = $v[1]->getResource();
    expect($r)->toContainKey('id');
    expect($r)->toContainKey('title');
    expect($r['id'])->toBeSame(1);
    expect($r['title'])->toBeSame('merge emmbedded resource');
  }
}
