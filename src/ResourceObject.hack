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

use namespace HH\Lib\{C, Vec};

final class ResourceObject<T as RootResource> {

  protected dict<string, Link> $links = dict[];

  protected dict<string, vec<T>> $embedded = dict[];

  public function withLink(Link $link): this {
    $new = clone $this;
    if (C\contains_key($new->links, $link->getLinkRelation())) {
      $vec = C\first(
        Vec\filter_with_key($new->links, ($k, $_) ==> $k === $link->getLinkRelation())
      );
      if($vec is nonnull) {
        $new->links = dict[
          $link->getLinkRelation() =>  new Link(
            $link->getLinkRelation(),
            Vec\concat($vec->getResource(), $link->getResource())
          )
        ];
        return $new;
      }
    }
    $new->links[$link->getLinkRelation()] = $link;
    return $new;
  }

  public function withEmbedded(
    string $embbeddedName,
    vec<T> $resource
  ): this {
    $new = clone $this;
    if (C\contains_key($new->embedded, $embbeddedName)) {
      $r = C\first(
        Vec\filter_with_key($new->embedded, ($k, $_) ==> $k === $embbeddedName)
      );
      if($r is nonnull) {
        $new->embedded[$embbeddedName] = Vec\concat($r, $resource);
        return $new;
      }
    }
    $new->embedded[$embbeddedName] = $resource;
    return $new;
  }

  public function getLinks(): dict<string, Link> {
    return $this->links;
  }

  public function getEmbedded(): dict<string, vec<T>> {
    return $this->embedded;
  }
}
