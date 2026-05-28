import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INDEX = ROOT / 'index.html'


class AppContractTests(unittest.TestCase):
    def test_index_exists(self):
        self.assertTrue(INDEX.exists(), 'index.html should exist at repo root')

    def test_required_sections_and_copy_exist(self):
        html = INDEX.read_text(encoding='utf-8')
        required_ids = [
            'heroTitle',
            'regionSearch',
            'institutionList',
            'supportFeed',
            'participationButtons',
        ]
        for token in required_ids:
            self.assertIn(token, html)

        required_copy = [
            '아이곁에',
            '지역 아동돌봄 연결 플랫폼',
            '기관 찾기',
            '지금 필요한 도움',
            '참여 방식',
        ]
        for token in required_copy:
            self.assertIn(token, html)

    def test_required_js_hooks_exist(self):
        html = INDEX.read_text(encoding='utf-8')
        required_hooks = [
            'const institutions =',
            'const supportNeeds =',
            'renderInstitutions(',
            'renderNeeds(',
            'applyFilter(',
        ]
        for token in required_hooks:
            self.assertIn(token, html)

        self.assertRegex(html, re.compile(r'<meta[^>]+name="viewport"', re.I))


if __name__ == '__main__':
    unittest.main()
