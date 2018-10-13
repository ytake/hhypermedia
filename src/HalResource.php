<?hh // strict

/**
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * This software consists of voluntary contributions made by many individuals
 * and is licensed under the MIT license.
 *
 * Copyright (c) 2018 Yuuki Takezawa
 *
 */
namespace Ytake\HHhal;

use function is_null;

class HalResource {

  protected Map<string, Link> $links = Map{};

  protected Map<string, Vector<HalResource>> $embedded = Map{};

  public function __construct(
    protected Map<mixed, mixed> $resources = Map{}
  ) {}
  
  public function addResource(mixed $key, mixed $value): this {
    $this->resources->add(Pair{$key, $value});
    return $this;
  }

  public function withLink(Link $link): this {
    if($this->links->containsKey($link->getRel())) {
      $rel = $this->links->get($link->getRel());
      if(!is_null($rel)) {
        $this->links = new Map([
          $link->getRel() =>  new Link(
            $link->getRel(), 
            $rel->getResource()->concat($link->getResource())
          )
        ]);
        return $this;
      }
    }
    $this->links->add(Pair{$link->getRel(), $link});
    return $this;
  }

  public function withEmbedded(
    string $embbeddedName,
    Vector<HalResource> $resource
  ): this {
    if ($this->embedded->containsKey($embbeddedName)) {
      $r = $this->embedded->get($embbeddedName);
      if(!is_null($r)) {
        $this->embedded->set($embbeddedName, $r->concat($resource));
        return $this;
      }
    }
    $this->embedded->add(
      Pair{$embbeddedName, $resource}
    );
    return $this;
  }

  public function getLinks(): Map<string, Link> {
    return $this->links;
  }

  public function getEmbedded(): Map<string, Vector<HalResource>> {
    return $this->embedded;
  }

  public function getResource(): Map<mixed, mixed> {
    return $this->resources;
  }
}
