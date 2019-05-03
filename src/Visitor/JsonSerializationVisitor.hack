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
namespace Ytake\Hhypermedia\Visitor;

use type RuntimeException;
use type Ytake\Hhypermedia\SerializationVisitorInterface;
use namespace HH\Lib\Str;
use function json_encode;
use function json_last_error;
use const JSON_ERROR_NONE;
use const JSON_ERROR_UTF8;
use const JSON_PRESERVE_ZERO_FRACTION;

final class JsonSerializationVisitor implements SerializationVisitorInterface {

  public function __construct(
    private int $option = JSON_PRESERVE_ZERO_FRACTION
  ) {}

  public function getResult(
    dict<arraykey, mixed> $data
  ): string {
    $result = @json_encode($data, $this->option);
    switch (json_last_error()) {
      case JSON_ERROR_NONE:
        return $result;
      case JSON_ERROR_UTF8:
        throw new RuntimeException(
          'Your data could not be encoded because it contains invalid UTF8 characters.'
        );
      default:
        throw new RuntimeException(
          Str\format(
            'An error occurred while encoding your data (error code %d).',
            json_last_error()
          )
        );
    }
  }
}
