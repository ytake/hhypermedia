use type Ytake\Hhypermedia\{Link, LinkResource};
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

class LinkTest extends HackTest {

  public function testShouldBeLinkObjects(): void {
    $link = new Link(
      'self',
      vec[new LinkResource('/tests')],
    );
    expect($link)->toBeInstanceOf(Link::class);
    expect($link->getLinkRelation())->toBeSame('self');
  }
}
