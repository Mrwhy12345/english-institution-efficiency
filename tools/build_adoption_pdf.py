from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    BaseDocTemplate,
    Frame,
    HRFlowable,
    KeepTogether,
    PageBreak,
    PageTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "output" / "pdf" / "cyana-data-foundation-adoption-brief.pdf"

NAVY = colors.HexColor("#173B57")
BLUE = colors.HexColor("#2F6B9A")
LIGHT_BLUE = colors.HexColor("#EAF3F9")
PALE_BLUE = colors.HexColor("#F5F9FC")
TEAL = colors.HexColor("#2D7A78")
LIGHT_TEAL = colors.HexColor("#E9F5F3")
GOLD = colors.HexColor("#C58B2A")
LIGHT_GOLD = colors.HexColor("#FFF6E4")
RED = colors.HexColor("#A94B45")
LIGHT_RED = colors.HexColor("#FAEEEC")
INK = colors.HexColor("#1F2D38")
MUTED = colors.HexColor("#61717D")
LINE = colors.HexColor("#D7E1E8")
WHITE = colors.white


def register_fonts():
    candidates = [
        ("CJK", "/System/Library/Fonts/STHeiti Light.ttc"),
        ("CJK-Bold", "/System/Library/Fonts/STHeiti Medium.ttc"),
    ]
    for name, path in candidates:
        pdfmetrics.registerFont(TTFont(name, path, subfontIndex=0))


register_fonts()

styles = getSampleStyleSheet()
styles.add(
    ParagraphStyle(
        name="CoverTitle",
        fontName="CJK-Bold",
        fontSize=27,
        leading=36,
        textColor=NAVY,
        alignment=TA_LEFT,
        spaceAfter=8 * mm,
    )
)
styles.add(
    ParagraphStyle(
        name="CoverSub",
        fontName="CJK",
        fontSize=12,
        leading=20,
        textColor=MUTED,
        spaceAfter=8 * mm,
    )
)
styles.add(
    ParagraphStyle(
        name="H1CN",
        fontName="CJK-Bold",
        fontSize=18,
        leading=25,
        textColor=NAVY,
        spaceBefore=2 * mm,
        spaceAfter=5 * mm,
    )
)
styles.add(
    ParagraphStyle(
        name="H2CN",
        fontName="CJK-Bold",
        fontSize=12,
        leading=18,
        textColor=BLUE,
        spaceBefore=4 * mm,
        spaceAfter=2.5 * mm,
    )
)
styles.add(
    ParagraphStyle(
        name="BodyCN",
        fontName="CJK",
        fontSize=9.5,
        leading=15.5,
        textColor=INK,
        spaceAfter=2.5 * mm,
    )
)
styles.add(
    ParagraphStyle(
        name="SmallCN",
        fontName="CJK",
        fontSize=8,
        leading=12,
        textColor=MUTED,
    )
)
styles.add(
    ParagraphStyle(
        name="BoxTitle",
        fontName="CJK-Bold",
        fontSize=9.5,
        leading=13,
        textColor=NAVY,
        alignment=TA_CENTER,
    )
)
styles.add(
    ParagraphStyle(
        name="BoxBody",
        fontName="CJK",
        fontSize=7.7,
        leading=11,
        textColor=INK,
        alignment=TA_CENTER,
    )
)
styles.add(
    ParagraphStyle(
        name="Callout",
        fontName="CJK-Bold",
        fontSize=12,
        leading=19,
        textColor=NAVY,
        alignment=TA_LEFT,
    )
)
styles.add(
    ParagraphStyle(
        name="TableHead",
        fontName="CJK-Bold",
        fontSize=8,
        leading=11,
        textColor=WHITE,
        alignment=TA_LEFT,
    )
)
styles.add(
    ParagraphStyle(
        name="TableCell",
        fontName="CJK",
        fontSize=7.5,
        leading=11,
        textColor=INK,
        alignment=TA_LEFT,
    )
)


def P(text, style="BodyCN"):
    return Paragraph(text, styles[style])


def arrow_cell():
    return P("→", "BoxTitle")


def box(title, body="", fill=LIGHT_BLUE, width=27):
    content = [P(title, "BoxTitle")]
    if body:
        content += [Spacer(1, 1.5 * mm), P(body, "BoxBody")]
    t = Table([[content]], colWidths=[width * mm], rowHeights=[24 * mm])
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), fill),
                ("BOX", (0, 0), (-1, -1), 0.8, BLUE),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 3 * mm),
                ("RIGHTPADDING", (0, 0), (-1, -1), 3 * mm),
                ("TOPPADDING", (0, 0), (-1, -1), 3 * mm),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3 * mm),
            ]
        )
    )
    return t


def flow_row(items, widths=None):
    row = []
    col_widths = []
    for idx, item in enumerate(items):
        row.append(item)
        col_widths.append((widths[idx] if widths else 27) * mm)
        if idx < len(items) - 1:
            row.append(arrow_cell())
            col_widths.append(7 * mm)
    table = Table([row], colWidths=col_widths)
    table.setStyle(
        TableStyle(
            [
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("ALIGN", (0, 0), (-1, -1), "CENTER"),
                ("LEFTPADDING", (0, 0), (-1, -1), 0),
                ("RIGHTPADDING", (0, 0), (-1, -1), 0),
                ("TOPPADDING", (0, 0), (-1, -1), 0),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
            ]
        )
    )
    return table


def callout(text, fill=LIGHT_GOLD, border=GOLD):
    t = Table([[P(text, "Callout")]], colWidths=[166 * mm])
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), fill),
                ("BOX", (0, 0), (-1, -1), 0.8, border),
                ("LEFTPADDING", (0, 0), (-1, -1), 6 * mm),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6 * mm),
                ("TOPPADDING", (0, 0), (-1, -1), 5 * mm),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 5 * mm),
            ]
        )
    )
    return t


def data_table(headers, rows, widths, header_bg=NAVY):
    data = [[P(h, "TableHead") for h in headers]]
    for row in rows:
        data.append([P(str(cell), "TableCell") for cell in row])
    t = Table(data, colWidths=[w * mm for w in widths], repeatRows=1)
    commands = [
        ("BACKGROUND", (0, 0), (-1, 0), header_bg),
        ("GRID", (0, 0), (-1, -1), 0.45, LINE),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 2.5 * mm),
        ("RIGHTPADDING", (0, 0), (-1, -1), 2.5 * mm),
        ("TOPPADDING", (0, 0), (-1, -1), 2.2 * mm),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 2.2 * mm),
    ]
    for idx in range(1, len(data)):
        commands.append(("BACKGROUND", (0, idx), (-1, idx), WHITE if idx % 2 else PALE_BLUE))
    t.setStyle(TableStyle(commands))
    return t


def bullet(text):
    return P(f"• {text}", "BodyCN")


def header_footer(canvas, doc):
    canvas.saveState()
    width, height = A4
    canvas.setStrokeColor(LINE)
    canvas.setLineWidth(0.5)
    canvas.line(20 * mm, height - 15 * mm, width - 20 * mm, height - 15 * mm)
    canvas.setFont("CJK", 7.5)
    canvas.setFillColor(MUTED)
    canvas.drawString(20 * mm, height - 11.5 * mm, "CYANA  |  教学-反馈数据基座采纳建议")
    canvas.drawRightString(width - 20 * mm, 10 * mm, f"{doc.page}")
    canvas.restoreState()


def build_story():
    story = []

    story += [
        Spacer(1, 18 * mm),
        P("Cyana 教学-反馈数据基座", "CoverTitle"),
        P("从机构流程理解，到最小数据抽象，再到三名学生反馈验证", "CoverSub"),
        callout("建议用一个班级开展两周试点：先把作业、作答、错题和反馈跑通，再依据真实效果决定扩展。"),
        Spacer(1, 12 * mm),
        P("我们对机构整体运作的理解", "H1CN"),
        P("英语培训机构不是六套孤立工作，而是一个从获客、教学到口碑回流的闭环。", "BodyCN"),
        flow_row(
            [
                box("市场", "定位·渠道·获客", width=22),
                box("营销", "咨询·试听·报名", width=22),
                box("教研", "课程·教材·题目", width=22),
                box("教学", "授课·作业·指导", LIGHT_TEAL, 22),
                box("测评", "作答·评分·错因", LIGHT_TEAL, 22),
                box("反馈", "学情·行动·沟通", LIGHT_GOLD, 22),
            ],
            widths=[22, 22, 22, 22, 22, 22],
        ),
        Spacer(1, 5 * mm),
        P("反馈推动教学调整，测评薄弱点回流教研，续费、转介绍和口碑再回到市场。", "SmallCN"),
        Spacer(1, 10 * mm),
        data_table(
            ["本阶段聚焦", "原因", "暂不扩张"],
            [["教学 + 反馈", "最接近学习结果，也是教师、家长和负责人最容易感知价值的环节", "不一次替代CRM、财务或完整排课系统"]],
            [30, 86, 50],
        ),
        PageBreak(),
    ]

    story += [
        P("01  教学-反馈的四个实际子流程", "H1CN"),
        P("教学和反馈之间，由测评分析能力完成连接。这里的“收集反馈”指收回学生作答、教师批注和必要的课堂观察。", "BodyCN"),
        Spacer(1, 4 * mm),
        flow_row(
            [
                box("1. 布置作业", "选材料与题目<br/>确认班级、截止时间和分值", LIGHT_TEAL, 35),
                box("2. 收集反馈", "收回PDF、照片或答案<br/>确认学生、任务和提交时间", LIGHT_TEAL, 35),
                box("3. 分析错题", "逐题比对<br/>计算得分<br/>识别错因与模式", LIGHT_BLUE, 35),
                box("4. 整理反馈", "表现<br/>问题<br/>建议<br/>跟进", LIGHT_GOLD, 35),
            ],
            widths=[35, 35, 35, 35],
        ),
        Spacer(1, 7 * mm),
        callout("最终形成的不是一段笼统评价，而是可以回到下一次教学任务的闭环：表现 - 问题 - 建议 - 跟进。", LIGHT_TEAL, TEAL),
        Spacer(1, 8 * mm),
        P("人与系统如何配合", "H2CN"),
        data_table(
            ["角色", "负责内容", "边界"],
            [
                ["教师 / 负责人", "确认学生身份、正式成绩、教学判断和对外反馈", "关键归属不由系统猜测"],
                ["数据基座", "保存原始事实、关联任务、复算成绩、追踪反馈", "不替代教师判断"],
                ["AI协作", "识别材料、整理错题、形成反馈草稿、主动询问缺失信息", "未经确认不写入关键事实"],
            ],
            [30, 76, 60],
        ),
        Spacer(1, 8 * mm),
        P("协作工作流", "H2CN"),
        flow_row(
            [
                box("识别材料", "提取文章、题目和答案", width=26),
                box("补齐信息", "询问学生、班级和日期", width=26),
                box("事务写入", "用写账号登记", width=26),
                box("独立验证", "用读账号复核", width=26),
                box("输出反馈", "针对错题给行动建议", width=26),
            ],
            widths=[26, 26, 26, 26, 26],
        ),
        PageBreak(),
    ]

    story += [
        P("02  把复杂流程抽象成最小数据结构", "H1CN"),
        P("抽象原则不是“每个动作建一张表”，而是识别稳定的业务事实：谁、在哪个学习组织、使用什么内容、完成什么任务、提交什么答案、得到什么反馈。", "BodyCN"),
        Spacer(1, 3 * mm),
        data_table(
            ["机构业务语言", "数据抽象", "一行代表什么"],
            [
                ["学生、家长、教师", "person / person_relation", "一个人员；一条人员关系"],
                ["课程、班级、成员", "learning_group / group_member", "一个学习组织；一次加入关系"],
                ["PDF、文章、题目", "content_item", "一个可复用内容对象"],
                ["作业、测评、题目顺序", "activity / activity_item", "一次任务；任务中的一道题"],
                ["学生提交、逐题答案", "submission / answer", "一次提交；对一道题的最终回答"],
                ["诊断、建议、跟进", "feedback", "针对一次提交的一次反馈"],
            ],
            [48, 58, 60],
        ),
        Spacer(1, 7 * mm),
        P("最小ER主链", "H2CN"),
        flow_row(
            [
                box("人员", "person", width=22),
                box("班级", "learning_group", width=22),
                box("任务", "activity", width=22),
                box("提交", "submission", width=22),
                box("答案", "answer", width=22),
                box("反馈", "feedback", width=22),
            ],
            widths=[22, 22, 22, 22, 22, 22],
        ),
        Spacer(1, 4 * mm),
        P("教学内容 content_item 通过 activity_item 进入任务；人员通过 group_member 加入课程或班级。", "SmallCN"),
        Spacer(1, 8 * mm),
        P("为什么10张表足够承载未来信息", "H2CN"),
        data_table(
            ["设计选择", "方法", "效果"],
            [
                ["稳定关系", "主键、外键、状态、时间、顺序和分值使用标准字段", "可查询、可约束、可统计"],
                ["变化较大的属性", "选项、量规、联系方式和低频属性使用JSON", "避免过早拆表，保留扩展空间"],
                ["延迟拆分", "只有出现独立生命周期、复用或明确指标需求时才新增表", "控制维护成本"],
                ["一机构一库", "Cyana使用inst_cyana，库内不重复institution_id", "边界清晰，后续机构可复制同一结构"],
            ],
            [36, 78, 52],
        ),
        PageBreak(),
    ]

    story += [
        P("03  不是只画ER图，而是完成工程验证", "H1CN"),
        P("模型通过六层证据链验证，从业务理解一直落到真实数据库读写。", "BodyCN"),
        Spacer(1, 4 * mm),
        flow_row(
            [
                box("业务闭环", "流程是否完整", width=22),
                box("数据粒度", "一行一个事实", width=22),
                box("ER关系", "主外键与基数", width=22),
                box("完整性", "唯一性与检查", width=22),
                box("指标血缘", "成绩能否复算", width=22),
                box("真实模拟", "写入后独立读取", width=22),
            ],
            widths=[22, 22, 22, 22, 22, 22],
        ),
        Spacer(1, 8 * mm),
        data_table(
            ["验证项", "实际证据", "结论"],
            [
                ["数据库", "MySQL 8.4.11，Cyana独立数据库inst_cyana", "可实际运行"],
                ["结构", "10张业务表 + 1张schema_version治理表", "满足当前最小闭环"],
                ["权限", "读账号只能查询；写账号只能写业务表，不能DDL", "日常操作与结构治理隔离"],
                ["材料", "Level D阅读材料“Look Out!”：4题，答案B/A/B/A", "真实材料可以结构化"],
                ["模拟", "3名学生、3次提交、12条逐题答案、3份反馈", "端到端链路完整"],
                ["计分", "3份总分与逐题汇总差值均为0", "分数可以从原始事实复算"],
            ],
            [34, 88, 44],
        ),
        Spacer(1, 7 * mm),
        P("验证带来的结构修正", "H2CN"),
        bullet("发现MySQL 8.4对answer标识符的处理问题，已通过2.0.1迁移修复。"),
        bullet("发现评分人外键动作与检查约束冲突，改为保留审计记录的ON DELETE RESTRICT。"),
        bullet("发现SOURCE遇错后仍可能继续登记版本，改为只有表和视图都存在时才记录成功版本。"),
        Spacer(1, 4 * mm),
        callout("这些问题是在真实建库、授权和写入过程中发现并修复的，证明方案不是停留在概念设计。", LIGHT_BLUE, BLUE),
        PageBreak(),
    ]

    story += [
        P("04  三名学生的模拟反馈输出", "H1CN"),
        P("同一份“Look Out!”阅读任务，4题、总分100。不同作答模式必须产生不同诊断和下一步行动。", "BodyCN"),
        Spacer(1, 4 * mm),
        data_table(
            ["学生", "结果", "表现", "问题", "建议与跟进"],
            [
                ["安安（模拟）", "4/4<br/>100分", "显性信息定位准确，动物关系链清楚", "本次无明显错误", "遮住图片复述关系链；再做1篇无图片提示阅读"],
                ["贝贝（模拟）", "3/4<br/>75分", "大部分细节能正确定位", "第2题未回到dog原句，相似选项下凭印象作答", "圈出主语dog，回原文划出宾语cat；补做2组主宾配对题"],
                ["辰辰（模拟）", "1/4<br/>25分", "第4题能正确定位“蜜蜂看到狗”", "前3题主客体混淆，部分选择脱离原文", "逐句画“谁看到谁”的箭头；教师带读后完成4道同结构题"],
            ],
            [25, 18, 39, 40, 44],
        ),
        Spacer(1, 8 * mm),
        P("从原始事实到反馈", "H2CN"),
        flow_row(
            [
                box("学生作答", "每题选择", width=35),
                box("逐题评分", "正确性与得分", width=35),
                box("错误模式", "错因代码与教师点评", width=35),
                box("反馈内容", "表现·问题·建议·跟进", width=35),
            ],
            widths=[35, 35, 35, 35],
        ),
        Spacer(1, 8 * mm),
        callout("负责人看到的不只是“AI写了三段话”，而是每段反馈都能回到具体题目、答案、得分和错因。", LIGHT_GOLD, GOLD),
        Spacer(1, 8 * mm),
        P("长期积累后可以回答", "H2CN"),
        data_table(
            ["个人", "班级", "材料与教研"],
            [["学生在哪类题上持续进步或反复出错", "哪些错因是班级共性，应该如何调整教学", "哪些材料过难、过易或最能暴露真实问题"]],
            [55, 56, 55],
        ),
        PageBreak(),
    ]

    story += [
        P("05  低风险试点与采纳决策", "H1CN"),
        P("先用最小范围验证教师是否省时、反馈是否更具体、数据是否完整，不立即全机构铺开。", "BodyCN"),
        Spacer(1, 4 * mm),
        data_table(
            ["阶段", "动作", "判断标准"],
            [
                ["第1周", "选择1名教师、1个班、3至10名学生，登记2次作业", "材料和答题完整登记；教师能理解反馈"],
                ["第2周", "持续登记，由教师确认和修改反馈", "记录处理耗时、教师修改率和遗漏信息"],
                ["复盘", "对比原流程与试点流程", "反馈更及时、更具体，教师负担下降"],
            ],
            [24, 82, 60],
        ),
        Spacer(1, 8 * mm),
        P("机构可以获得什么", "H2CN"),
        bullet("教师：减少重复整理，反馈直接指向错题和行动。"),
        bullet("教研：识别高频错因、材料难度和需要调整的教学内容。"),
        bullet("负责人：追踪作业完成、评分一致性和反馈及时性。"),
        bullet("家长：收到“表现 - 问题 - 建议 - 跟进”，而不只是分数。"),
        Spacer(1, 5 * mm),
        P("边界与风险控制", "H2CN"),
        bullet("AI不擅自判断学生身份、班级和正式成绩；缺少关键归属时主动请教师补充。"),
        bullet("读写账号与结构管理账号分离，结构变更必须执行迁移并验证。"),
        bullet("原始材料、识别结果、教师确认和对外反馈保持可追溯。"),
        bullet("当前优先解决教学反馈闭环，不宣称替代完整经营系统。"),
        Spacer(1, 6 * mm),
        callout("需要负责人批准：指定试点教师和班级，允许使用经授权或脱敏的学生作业，两周后依据数据质量、教师耗时和反馈价值决定是否扩大。", LIGHT_TEAL, TEAL),
        Spacer(1, 8 * mm),
        P("采纳核心", "H2CN"),
        P("先理解流程，再把复杂流程抽象成可验证的数据事实；先用最小结构跑通真实闭环，再由真实需求推动扩展。", "Callout"),
        Spacer(1, 10 * mm),
        HRFlowable(width="100%", thickness=0.6, color=LINE),
        Spacer(1, 3 * mm),
        P("版本：Cyana最小数据基座 2.0.1  |  形成日期：2026-08-03  |  模拟数据使用SIM_前缀", "SmallCN"),
    ]
    return story


def main():
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    doc = BaseDocTemplate(
        str(OUTPUT),
        pagesize=A4,
        leftMargin=20 * mm,
        rightMargin=20 * mm,
        topMargin=22 * mm,
        bottomMargin=17 * mm,
        title="Cyana 教学-反馈数据基座采纳建议",
        author="Cyana 数据基座项目",
        subject="最小数据结构、ER验证和三名学生模拟反馈",
    )
    frame = Frame(doc.leftMargin, doc.bottomMargin, doc.width, doc.height, id="main")
    doc.addPageTemplates([PageTemplate(id="standard", frames=[frame], onPage=header_footer)])
    doc.build(build_story())
    print(OUTPUT)


if __name__ == "__main__":
    main()
