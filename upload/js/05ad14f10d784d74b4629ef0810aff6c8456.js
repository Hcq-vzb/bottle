document.addEventListener('DOMContentLoaded', function () {
    //判断是什么语言
    const Language_Query = {
        'zh_CN': '询盘邮件',
        'zh_HN': '詢盤郵件',
        'en': 'Inquiry email',
        'de': 'Anfrage-E-Mail',
        'fr': 'E-mail de demande',
        'ru': 'Запрос по электронной почте',
        'pt': 'E-mail de consulta',
        'ko': '문의 메일',
        'ja': 'お問い合わせメール',
        'es': 'Correo electrónico de consulta',
        'ar': 'البريد الإلكتروني للاستفسار',
        'it': 'E-mail di richiesta',
        'bn': 'তদন্ত ইমেল',
        'da': 'Forespørgselsmail',
        'idn': 'Email pertanyaan',
        'th': 'อีเมลสอบถาม',
        'vi': 'Email yêu cầu',
        'tr': 'Soruşturma e-postası',
        'nl': 'E-mail voor aanvraag',
        'pl': 'Zapytanie e-mailowe',
        'cs': 'Email s dotazem',
        'ee': 'Päringu email',
        'fi': 'Tiedustelu sähköposti',
        'el': 'Επικοινωνία email',
        'hu': 'Érdeklődő email',
        'gg': 'Имейл за запитване',
        'hr': 'E-pošta za upit',
        'ga': 'Ríomhphost fiosrúcháin',
        'ro': 'E-mail de întrebare',
        'lv': 'Uzziņas e-pasts',
        'mt': 'Email tal-Inkjesta',
        'sk': 'E-mail s dopytom',
        'si': 'E-pošta za povpraševanje',
        'sv': 'Förfrågningsmail',
        'lt': 'Užklausos el',
        'ml': 'E-mel pertanyaan',
        'bur': 'စုံစမ်းမေးမြန်းရန်အီးမေးလ်',
        'kh': 'អ៊ីមែលសាកសួរ',
        'la': 'ສອບຖາມອີເມລ໌',
        'ph': 'Email ng pagtatanong',
        'fa': 'ایمیل استعلام',
        'uk': 'Електронна пошта для запиту',
        'ta': 'விசாரணை மின்னஞ்சல்',
        'mn': 'Лавлагааны имэйл',
        'kk': 'Сұрау электрондық поштасы'

    };

    //循环A链接
    const A_tag = document.querySelectorAll('a');
    let language = window.tenant.language;
    if (!language) {
        language = 'en';
    }
    const inquirySubjectText = Language_Query[language] || Language_Query['en'];

    // 获取当前页面域名并赋值给currentDomain
    const currentDomain = window.location.hostname;

    A_tag.forEach((link) => {
        const href = link.href;
        //拼接邮件主题内容，判断逻辑，避免重复添加subject
        if (inquirySubjectText && href.includes('mailto:')) {
            const existingSubjectIndex = href.indexOf('?subject=');
            if (existingSubjectIndex === -1) {
                link.href = href + '?subject=' + inquirySubjectText;
            }
            link.rel = 'nofollow';
        }

        if (href.indexOf('javascript')!== -1) {
            return;
        }

        const isExternalLink =!href.includes(currentDomain);
        if (isExternalLink) {
            link.target = '_blank';
            link.rel = 'nofollow';
        }
    });
});