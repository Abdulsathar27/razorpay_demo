import re
from pathlib import Path
from xml.sax.saxutils import escape

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import Paragraph, Preformatted, SimpleDocTemplate, Spacer


def build_pdf(md_path: Path, pdf_path: Path) -> None:
    styles = getSampleStyleSheet()

    h1 = ParagraphStyle(
        'H1',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        spaceAfter=10,
        textColor=colors.HexColor('#111111'),
    )
    h2 = ParagraphStyle(
        'H2',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=14,
        leading=18,
        spaceBefore=10,
        spaceAfter=6,
        textColor=colors.HexColor('#1f1f1f'),
    )
    h3 = ParagraphStyle(
        'H3',
        parent=styles['Heading3'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        spaceBefore=8,
        spaceAfter=4,
    )
    body = ParagraphStyle(
        'Body',
        parent=styles['BodyText'],
        fontName='Helvetica',
        fontSize=10.5,
        leading=14,
        spaceAfter=4,
    )
    bullet = ParagraphStyle(
        'Bullet',
        parent=body,
        leftIndent=14,
        firstLineIndent=-8,
    )
    code = ParagraphStyle(
        'Code',
        parent=body,
        fontName='Courier',
        fontSize=9,
        leading=12,
        backColor=colors.HexColor('#f3f3f3'),
        leftIndent=6,
        rightIndent=6,
        spaceBefore=4,
        spaceAfter=6,
    )

    story = []
    in_code = False
    code_lines = []

    lines = md_path.read_text(encoding='utf-8').splitlines()

    def flush_code() -> None:
        nonlocal code_lines
        if code_lines:
            story.append(Preformatted('\n'.join(code_lines), code))
            code_lines = []

    for raw in lines:
        line = raw.rstrip('\n')
        stripped = line.strip()

        if stripped.startswith('```'):
            if in_code:
                flush_code()
                in_code = False
            else:
                in_code = True
            continue

        if in_code:
            code_lines.append(line)
            continue

        if not stripped:
            story.append(Spacer(1, 6))
            continue

        if stripped.startswith('# '):
            story.append(Paragraph(escape(stripped[2:].strip()), h1))
            continue

        if stripped.startswith('## '):
            story.append(Paragraph(escape(stripped[3:].strip()), h2))
            continue

        if stripped.startswith('### '):
            story.append(Paragraph(escape(stripped[4:].strip()), h3))
            continue

        if re.match(r'^\d+\.\s+', stripped):
            story.append(Paragraph(escape(stripped), body))
            continue

        if stripped.startswith('- '):
            story.append(Paragraph(escape(stripped[2:].strip()), bullet, bulletText='-'))
            continue

        if stripped.startswith('http://') or stripped.startswith('https://'):
            url = escape(stripped)
            story.append(Paragraph(f'<link href="{url}">{url}</link>', body))
            continue

        story.append(Paragraph(escape(stripped), body))

    if in_code:
        flush_code()

    doc = SimpleDocTemplate(
        str(pdf_path),
        pagesize=A4,
        leftMargin=1.7 * cm,
        rightMargin=1.7 * cm,
        topMargin=1.6 * cm,
        bottomMargin=1.6 * cm,
        title='Razorpay Setup and Debug Guide',
        author='Codex Assistant',
    )
    doc.build(story)


if __name__ == '__main__':
    base = Path.cwd()
    md = base / 'docs' / 'razorpay_setup_and_debug_guide.md'
    pdf = base / 'docs' / 'razorpay_setup_and_debug_guide.pdf'
    build_pdf(md, pdf)
    print(pdf)
