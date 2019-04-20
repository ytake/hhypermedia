use type Ytake\HHhal\{CurieResource, LinkResource};
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class CurieResourceTest extends HackTest {

  public function testShouldBeHalResourceObject(): void {
    $resource = new CurieResource(
      'http://haltalk.herokuapp.com/docs/{rel}',
      shape('name' => 'heroku')
    );
    expect($resource)->toBeInstanceOf(LinkResource::class);
    $atrs = $resource->getAttributes();
    expect(Shapes::idx($atrs, 'name'))->toBeSame('heroku');
    expect($resource->isTemplated())->toBeTrue();
  }
}
