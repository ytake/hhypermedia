<?hh // strict

use PHPUnit\Framework\TestCase;
use Ytake\HHhal\Link;
use Ytake\HHhal\HalResource;

final class HalResourceTest extends TestCase {

  public function testShouldBeHalResource(): void {
    $hal = new HalResource("/testing");
    $hal->withLink(new Link(
      ImmVector{ "tests" },
      "/root"
    ));
    $this->assertInstanceOf(HalResource::class, $hal);
  }
}

