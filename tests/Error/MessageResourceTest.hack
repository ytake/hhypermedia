use type Ytake\Hhypermedia\LinkResource;
use type Ytake\Hhypermedia\Error\ErrorLink;
use type Ytake\Hhypermedia\Error\MessageResource;
use type Ytake\Hhypermedia\ResourceObject;
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class MessageResourceTest extends HackTest {

  public function testShouldReturnErrorMessage(): void {
    $linkVec = vec[new LinkResource('http://...', shape())];
    $new = new ResourceObject()
    |> $$->withLink( new ErrorLink('help', $linkVec));
    $attributes = dict['logref' => 42, 'path' => '/'];
    $message = new MessageResource(
      'Validation failed',
      $new,
      shape('logref' => 42, 'path' => '/'),
      dict[]
    );
    expect($message->getAttributes())->toBeSame($attributes);
    expect(\count($message->getEmbedded()))->toBeSame(0);
    $links = $message->getLinks();
    expect($links['help']->getLinkRelation())->toBeSame('help');
    expect($links['help']->getResource())->toBeSame($linkVec);
  }

  public function testShouldReturnNestedErrorMessage(): void {

    $embedNew = new ResourceObject()
    |> $$->withLink(new ErrorLink('about', vec[
      new LinkResource('http://path.to/user/resource/1')
    ]));
    $message = new MessageResource(
      'Username must contain at least three characters',
      $embedNew,
      shape('path' => '/username')
    );
    $linkVec = vec[new LinkResource('http://...', shape())];
    $new = new ResourceObject()
    |> $$->withLink(new ErrorLink('help', $linkVec))
    |> $$->withLink(new ErrorLink('describes', $linkVec))
    |> $$->withLink(new ErrorLink('about', $linkVec))
    |> $$->withEmbedded('errors', vec[$message]);

    $attributes = shape('logref' => 42, 'path' => '/');
    $message = new MessageResource('Validation failed', $new, $attributes);
    $embbeded = $message->getEmbedded();
    expect(\count($embbeded))->toBeSame(1);
    expect($embbeded['errors'][0])->toBeInstanceOf(MessageResource::class);
  }
}
