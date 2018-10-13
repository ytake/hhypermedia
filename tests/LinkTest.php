<?hh // strict

use type Ytake\HHhal\{Link, LinkResource};
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

class LinkTest extends HackTest {

  public function testShouldBeLinkObjects(): void {
    $link = new Link(
      'self',
      new Vector([new LinkResource('/tests')]),
    );
    expect($link)->toBeInstanceOf(Link::class);
    expect($link->getRel())->toBeSame('self');
  }
}
