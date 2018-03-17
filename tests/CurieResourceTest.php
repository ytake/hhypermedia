<?hh //strict

use Ytake\HHhal\{CurieResource, Link, LinkResource};
use PHPUnit\Framework\TestCase;

class CurieResourceTest extends TestCase {

  public function testShouldBeHalResourceObject(): void {
    $resource = new CurieResource(
      'http://haltalk.herokuapp.com/docs/{rel}',
      shape('name' => 'heroku')
    );
    $this->assertInstanceOf(LinkResource::class, $resource);
    $atrs = $resource->getAttributes();
    $this->assertSame('heroku', Shapes::idx($atrs, 'name'));
    $this->assertTrue($resource->isTemplated());
  }
}
