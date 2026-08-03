from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "output" / "pdf" / "cyana-data-foundation-adoption-brief.pdf"

NAVY = colors.HexColor("#173B57")
BLUE = colors.HexColor("#2F6B9A")
LIGHT_BLUE = colors.HexColor("#EAF3F9")
PALE_BLUE = colors.HexColor("#F6FAFC")
TEAL = colors.HexColor("#2D7A78")
LIGHT_TEAL = colors.HexColor("#E9F5F3")
GOLD = colors.HexColor("#C58B2A")
LIGHT_GOLD = colors.HexColor("#FFF6E4")
INK = colors.HexColor("#1F2D38")
MUTED = colors.HexColor("#61717D")
LINE = colors.HexColor("#D4E0E7")
WHITE = colors.white


pdfmetrics.registerFont(
    TTFont("CJK", "/System/Library/Fonts/STHeiti Light.ttc", subfontIndex=0)
)
pdfmetrics.registerFont(
    TTFont("CJK-Bold", "/System/Library/Fonts/STHeiti Medium.ttc", subfontIndex=0)
)


def wrap_text(text, font_name, font_size, max_width):
    lines = []
    current = ""
    for char in text:
        candidate = current + char
        if current and pdfmetrics.stringWidth(candidate, font_name, font_size) > max_width:
            lines.append(current)
            current = char
        else:
            current = candidate
    if current:
        lines.append(current)
    return lines


def draw_centered_lines(c, text, x, y, width, height, font_name="CJK", font_size=7.5,
                        color=INK, leading=None):
    leading = leading or font_size * 1.45
    lines = []
    for paragraph in text.split("\n"):
        lines.extend(wrap_text(paragraph, font_name, font_size, width - 8))
    total_height = len(lines) * leading
    baseline = y + (height + total_height) / 2 - leading
    c.setFont(font_name, font_size)
    c.setFillColor(color)
    for line in lines:
        c.drawCentredString(x + width / 2, baseline, line)
        baseline -= leading


def draw_left_lines(c, text, x, y, width, font_name="CJK", font_size=8,
                    color=INK, leading=None, max_lines=None):
    leading = leading or font_size * 1.5
    lines = []
    for paragraph in text.split("\n"):
        lines.extend(wrap_text(paragraph, font_name, font_size, width))
    if max_lines:
        lines = lines[:max_lines]
    c.setFont(font_name, font_size)
    c.setFillColor(color)
    cursor = y
    for line in lines:
        c.drawString(x, cursor, line)
        cursor -= leading
    return cursor


def rounded_box(c, x, y, w, h, fill=LIGHT_BLUE, stroke=BLUE, radius=4,
                line_width=0.8):
    c.setFillColor(fill)
    c.setStrokeColor(stroke)
    c.setLineWidth(line_width)
    c.roundRect(x, y, w, h, radius, fill=1, stroke=1)


def arrow(c, x1, y1, x2, y2, color=BLUE):
    c.setStrokeColor(color)
    c.setFillColor(color)
    c.setLineWidth(1)
    c.line(x1, y1, x2, y2)
    size = 3
    c.line(x2, y2, x2 - size, y2 + size / 1.6)
    c.line(x2, y2, x2 - size, y2 - size / 1.6)


def section_label(c, number, title, x, y):
    c.setFont("CJK-Bold", 10.5)
    c.setFillColor(BLUE)
    c.drawString(x, y, f"{number}  {title}")


def stage_flow(c, x, y, total_width):
    stages = [
        ("市场", "定位·渠道·获客", LIGHT_BLUE),
        ("营销", "咨询·试听·报名", LIGHT_BLUE),
        ("教研", "课程·教材·题目", LIGHT_BLUE),
        ("教学", "授课·作业·指导", LIGHT_TEAL),
        ("测评", "作答·评分·错因", LIGHT_TEAL),
        ("反馈", "学情·行动·沟通", LIGHT_GOLD),
    ]
    gap = 17
    box_w = (total_width - gap * 5) / 6
    box_h = 37
    for idx, (title, body, fill) in enumerate(stages):
        bx = x + idx * (box_w + gap)
        rounded_box(c, bx, y, box_w, box_h, fill=fill)
        c.setFont("CJK-Bold", 8.5)
        c.setFillColor(NAVY)
        c.drawCentredString(bx + box_w / 2, y + 23, title)
        c.setFont("CJK", 6.4)
        c.setFillColor(MUTED)
        c.drawCentredString(bx + box_w / 2, y + 10, body)
        if idx < len(stages) - 1:
            arrow(c, bx + box_w + 3, y + box_h / 2, bx + box_w + gap - 3, y + box_h / 2)


def workflow_panel(c, x, y, w, h):
    rounded_box(c, x, y, w, h, fill=PALE_BLUE, stroke=LINE)
    section_label(c, "01", "教学-反馈的四个子流程", x + 12, y + h - 20)
    steps = [
        ("1. 布置作业", "材料·题目·班级·分值", LIGHT_TEAL),
        ("2. 收集反馈", "PDF·照片·答案·批注", LIGHT_TEAL),
        ("3. 分析错题", "逐题评分·错因模式", LIGHT_BLUE),
        ("4. 整理反馈", "表现·问题·建议·跟进", LIGHT_GOLD),
    ]
    gap = 14
    inner_x = x + 12
    inner_w = w - 24
    box_w = (inner_w - gap * 3) / 4
    box_y = y + 48
    box_h = 52
    for idx, (title, body, fill) in enumerate(steps):
        bx = inner_x + idx * (box_w + gap)
        rounded_box(c, bx, box_y, box_w, box_h, fill=fill)
        c.setFont("CJK-Bold", 7.8)
        c.setFillColor(NAVY)
        c.drawCentredString(bx + box_w / 2, box_y + 33, title)
        draw_centered_lines(c, body, bx + 3, box_y + 5, box_w - 6, 22,
                            font_size=6.3, color=MUTED)
        if idx < 3:
            arrow(c, bx + box_w + 2, box_y + box_h / 2,
                  bx + box_w + gap - 2, box_y + box_h / 2)
    c.setFont("CJK", 7)
    c.setFillColor(MUTED)
    c.drawString(x + 12, y + 25, "人确认关键归属与教学判断；系统保存事实、复算成绩并形成反馈草稿。")
    c.setFont("CJK-Bold", 7.5)
    c.setFillColor(TEAL)
    c.drawRightString(x + w - 12, y + 25, "反馈回到下一次教学任务")


def mysql_panel(c, x, y, w, h):
    rounded_box(c, x, y, w, h, fill=LIGHT_BLUE, stroke=BLUE, radius=7, line_width=1.2)
    c.setFont("CJK-Bold", 13)
    c.setFillColor(NAVY)
    c.drawString(x + 14, y + h - 23, "MySQL 8.4 统一数据基座")
    c.setFont("CJK", 7.2)
    c.setFillColor(MUTED)
    c.drawRightString(x + w - 14, y + h - 21, "inst_cyana · 版本2.0.1")

    rounded_box(c, x + 14, y + h - 52, w - 28, 20, fill=WHITE, stroke=LINE)
    c.setFont("CJK-Bold", 8.2)
    c.setFillColor(BLUE)
    c.drawCentredString(x + w / 2, y + h - 45, "10张业务表 + 1张结构治理表 · 一机构一库")

    names = ["人员", "班级", "任务", "提交", "答案", "反馈"]
    gap = 12
    chain_x = x + 14
    chain_w = w - 28
    box_w = (chain_w - gap * 5) / 6
    box_y = y + 48
    for idx, name in enumerate(names):
        bx = chain_x + idx * (box_w + gap)
        rounded_box(c, bx, box_y, box_w, 34, fill=WHITE, stroke=BLUE)
        c.setFont("CJK-Bold", 7.2)
        c.setFillColor(NAVY)
        c.drawCentredString(bx + box_w / 2, box_y + 20, name)
        table_name = ["person", "group", "activity", "submission", "answer", "feedback"][idx]
        c.setFont("CJK", 5.6)
        c.setFillColor(MUTED)
        c.drawCentredString(bx + box_w / 2, box_y + 9, table_name)
        if idx < 5:
            arrow(c, bx + box_w + 1, box_y + 17, bx + box_w + gap - 1, box_y + 17)

    c.setFont("CJK", 6.8)
    c.setFillColor(MUTED)
    c.drawString(x + 14, y + 26, "内容与题目：content_item / activity_item")
    c.drawRightString(x + w - 14, y + 26, "人员关系与成员：person_relation / group_member")


def student_card(c, x, y, w, h, name, score, finding, action, fill):
    rounded_box(c, x, y, w, h, fill=fill, stroke=LINE)
    c.setFont("CJK-Bold", 9)
    c.setFillColor(NAVY)
    c.drawString(x + 9, y + h - 17, name)
    c.setFont("CJK-Bold", 11)
    c.setFillColor(BLUE)
    c.drawRightString(x + w - 9, y + h - 17, score)
    draw_left_lines(c, f"发现：{finding}", x + 9, y + h - 34, w - 18,
                    font_size=6.7, color=INK, leading=10, max_lines=2)
    draw_left_lines(c, f"下一步：{action}", x + 9, y + 21, w - 18,
                    font_size=6.7, color=MUTED, leading=10, max_lines=2)


def evidence_panel(c, x, y, w, h):
    rounded_box(c, x, y, w, h, fill=PALE_BLUE, stroke=LINE)
    section_label(c, "03", "三名学生验证：反馈可追溯到逐题事实", x + 12, y + h - 20)
    gap = 10
    cards_x = x + 12
    cards_w = w - 24
    card_w = (cards_w - gap * 2) / 3
    card_y = y + 36
    card_h = 70
    student_card(c, cards_x, card_y, card_w, card_h, "安安（模拟）", "100分",
                 "4/4，显性信息定位准确", "遮图复述关系链", LIGHT_TEAL)
    student_card(c, cards_x + card_w + gap, card_y, card_w, card_h, "贝贝（模拟）", "75分",
                 "第2题未回到dog原句", "圈主语，再划原文宾语", LIGHT_BLUE)
    student_card(c, cards_x + (card_w + gap) * 2, card_y, card_w, card_h, "辰辰（模拟）", "25分",
                 "主客体混淆", "画“谁看到谁”的箭头", LIGHT_GOLD)
    c.setFont("CJK-Bold", 7.2)
    c.setFillColor(TEAL)
    c.drawString(x + 12, y + 16, "验证结果：3次提交 · 12条逐题答案 · 3份针对性反馈 · 总分与逐题汇总差值全部为0")


def decision_panel(c, x, y, w, h):
    rounded_box(c, x, y, w, h, fill=LIGHT_GOLD, stroke=GOLD, radius=6, line_width=1.1)
    section_label(c, "04", "负责人需要认可的决策", x + 12, y + h - 20)
    bullets = [
        "认可当前MySQL最小结构作为统一数据底座。",
        "未来新增字段或表必须通过迁移、验证和版本登记。",
        "只有真实业务需求触发扩展，不按临时表格随意生长。",
    ]
    cursor = y + h - 43
    for idx, text in enumerate(bullets, start=1):
        c.setFillColor(GOLD)
        c.circle(x + 18, cursor + 2, 7, fill=1, stroke=0)
        c.setFillColor(WHITE)
        c.setFont("CJK-Bold", 7)
        c.drawCentredString(x + 18, cursor, str(idx))
        draw_left_lines(c, text, x + 31, cursor + 5, w - 43,
                        font_name="CJK-Bold", font_size=7.1, color=NAVY,
                        leading=10, max_lines=2)
        cursor -= 25
    rounded_box(c, x + 12, y + 8, w - 24, 25, fill=WHITE, stroke=GOLD)
    draw_centered_lines(c, "先稳住底座，再按规则扩展：数据越积越有序，而不是越做越乱。",
                        x + 16, y + 8, w - 32, 25,
                        font_name="CJK-Bold", font_size=8.2, color=NAVY)


def build_pdf():
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    page_size = landscape(A4)
    c = canvas.Canvas(str(OUTPUT), pagesize=page_size)
    c.setTitle("Cyana MySQL教学反馈数据基座采纳建议")
    c.setAuthor("Cyana 数据基座项目")
    c.setSubject("一页说明机构流程、最小数据结构、模拟验证与采纳决策")

    width, height = page_size
    margin = 10 * mm

    c.setFont("CJK-Bold", 22)
    c.setFillColor(NAVY)
    c.drawString(margin, height - 22 * mm, "Cyana 教学-反馈数据基座｜一页采纳建议")
    c.setFont("CJK", 8.5)
    c.setFillColor(MUTED)
    c.drawRightString(width - margin, height - 20.5 * mm,
                      "目标：认可当前MySQL结构，后续有序扩展")

    rounded_box(c, margin, height - 42 * mm, width - 2 * margin, 14 * mm,
                fill=LIGHT_GOLD, stroke=GOLD, radius=5, line_width=1)
    draw_centered_lines(
        c,
        "建议：以当前10张业务表 + 1张治理表作为Cyana统一数据基座。先跑通教学反馈闭环，未来通过迁移和验证扩展，避免数据失控。",
        margin + 8, height - 42 * mm, width - 2 * margin - 16, 14 * mm,
        font_name="CJK-Bold", font_size=10, color=NAVY,
    )

    section_label(c, "00", "我们理解机构六大环节，并聚焦教学到反馈的闭环",
                  margin, height - 49 * mm)
    stage_flow(c, margin, height - 70 * mm, width - 2 * margin)

    gap = 6 * mm
    middle_y = height - 126 * mm
    middle_h = 47 * mm
    left_w = 139 * mm
    workflow_panel(c, margin, middle_y, left_w, middle_h)
    mysql_panel(c, margin + left_w + gap, middle_y,
                width - 2 * margin - left_w - gap, middle_h)

    bottom_y = 17 * mm
    bottom_h = 50 * mm
    evidence_w = 175 * mm
    evidence_panel(c, margin, bottom_y, evidence_w, bottom_h)
    decision_panel(c, margin + evidence_w + gap, bottom_y,
                   width - 2 * margin - evidence_w - gap, bottom_h)

    c.setStrokeColor(LINE)
    c.line(margin, 11 * mm, width - margin, 11 * mm)
    c.setFont("CJK", 6.5)
    c.setFillColor(MUTED)
    c.drawString(margin, 7 * mm, "MySQL 8.4.11 · inst_cyana · schema 2.0.1 · 模拟数据使用SIM_前缀")
    c.drawRightString(width - margin, 7 * mm, "建议试点：1名教师 · 1个班 · 3至10名学生 · 2周")

    c.showPage()
    c.save()
    print(OUTPUT)


if __name__ == "__main__":
    build_pdf()
