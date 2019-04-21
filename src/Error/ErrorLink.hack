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
 * Copyright (c) 2018-2019 Yuuki Takezawa
 *
 */
namespace Ytake\HHhal\Error;

use type Ytake\HHhal\Link;
use type Ytake\HHhal\LinkResource;

enum LinkRelation: string as string {
  HELP = 'help';
  DESCRIBES = 'describes';
  ABOUT = 'about';
}

final class ErrorLink extends Link {

  public function __construct(
    protected string $linkRelation,
    protected vec<LinkResource> $link
  ) {
    parent::__construct(
      LinkRelation::assert($linkRelation),
      $link
    );
  }
}
