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
namespace Ytake\Hhypermedia\Error;

use type Ytake\Hhypermedia\Link;
use type Ytake\Hhypermedia\ResourceObject;
use type Ytake\Hhypermedia\ErrorAttributes;
use type Ytake\Hhypermedia\RootResource;

/**
 * @see https://github.com/blongden/vnd.error
 */
class MessageResource implements RootResource {

  public function __construct(
    private string $errorMessge,
    private ResourceObject<this> $resourceObject,
    private ErrorAttributes $attributes = shape()
  ) {}

  public function getErrorMesage(): string {
    return $this->errorMessge;
  }

  public function getLinks(): dict<string, Link> {
    return $this->resourceObject->getLinks();
  }

  public function getEmbedded(): dict<string, vec<this>> {
    return $this->resourceObject->getEmbedded();
  }

  public function getAttributes(): ErrorAttributes {
    return $this->attributes;
  }
}
