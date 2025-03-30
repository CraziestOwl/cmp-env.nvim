import json
import os
import random
import re
import string
from typing import Generator

ALL = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&()*+,-./:;<=>?@[\\]^_`{|}~ \t\n'
ENDS = string.ascii_letters + string.digits
NAMES = string.ascii_uppercase + string.digits
NO_QUOTES = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!%*+,-./:=?@[\\]^_~'
def get_comment_line() -> str:
    length = random.randint(10, 30) - 2
    if random.randint(0, 1):
        key = random.choice(string.ascii_uppercase) + ''.join(random.choices(NAMES+'_', k=random.randint(2, 10))) + random.choice(NAMES)
        line = key + '='+random.choice(ENDS) + ''.join(random.choices(NO_QUOTES, k=length)) + random.choice(ENDS)
    else:
        line = ''.join(random.choices(NO_QUOTES, k=length))
    return line + "\n"

def gen_value(num: int) -> Generator[tuple[str, str], None, None]:
    for _ in range(num):
        use_quotes = random.randint(0, 1)
        key = random.choice(string.ascii_uppercase) + ''.join(random.choices(NAMES+'_', k=random.randint(2, 10))) + random.choice(NAMES)
        if use_quotes:
            length = random.randint(10, 100) - 2
            value = "'" + random.choice(ENDS) + "".join(random.choices(ALL, k=length)) + random.choice(ENDS) + "'"
        else:
            length = random.randint(10, 30) - 2
            value = random.choice(ENDS) + ''.join(random.choices(NO_QUOTES, k=length)) + random.choice(ENDS)
        # remove empty lines in string
        value = re.sub(r'\n{2,}', '\n', value)
        yield key, value

envs = []
if __name__ == "__main__":
    tests_path = os.path.abspath(os.path.join(os.path.dirname(__file__), 'cmp_env', 'cases'))
    os.makedirs(tests_path, exist_ok=True)
    with (open(os.path.join(tests_path, 'test_envs'), 'w') as fp,
          open(os.path.join(tests_path, 'test_envs_with_comments'), 'w') as fp1,
          open(os.path.join(tests_path, 'test_envs_without_export'), 'w') as fp2,
          open(os.path.join(tests_path, 'test_envs_without_export_with_comments'), 'w') as fp3):
        for k, v in gen_value(1000):
            for _ in range(random.randint(0, 3)):
                comment = get_comment_line()
                fp1.write("# export " + comment)
                fp3.write("# " + comment)
            fp.write(f'export {k}={v}\n')
            fp1.write(f'export {k}={v}\n')
            fp2.write(f'{k}={v}\n')
            fp3.write(f'{k}={v}\n')
            envs.append((k, v))
    with open(os.path.join(tests_path, 'expected_values.json'), 'w') as fp:
        json.dump(envs, fp)
