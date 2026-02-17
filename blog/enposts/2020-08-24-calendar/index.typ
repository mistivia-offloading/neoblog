// Calculation of the Lunar Calendar
#import "/template-en.typ":*

#doc-template(
title: "Calculation of the Lunar Calendar",
date: "August 24, 2020",
body: [

The Gregorian calendar, which is the current international calendar, is something most people learned in primary school, and its rules are very simple. But the Lunar Calendar (Nongli) is different; every year the Spring Festival seems to change, it's never on the same day as Lichun (Beginning of Spring), yet it's always near it. Leap months are even more confusing—any month could potentially be a leap month.

Therefore, in this article, I want to write about how the Lunar Calendar is organized.

= Three Variables of Calendars

There are many types of calendars in the world, which can be roughly categorized into lunar calendars, solar calendars, and lunisolar calendars. These calendars use nothing more than three variables: the diurnal cycle (day), the Earth's orbital period (year), and the Moon's phase cycle (month). Note that I say the Moon's phase cycle rather than its orbital period. The specific reason will be explained later.

Different calendars combine these three variables. The Gregorian calendar is a solar calendar; it chose "day" and "year" and abandoned the phase cycle of the Moon. Therefore, the months in the Gregorian calendar are merely symbolic. The Islamic calendar is a lunar calendar; it fits "day" and "month" and completely ignores the Earth's orbit. Thus, the Islamic calendar does not match the Earth's revolution, and some Islamic festivals can appear in any season. The Chinese Lunar Calendar chose the most difficult mode: the lunisolar calendar. That is, it must consider both the Moon's phases and the Earth's orbit.

= How to Define a Year

If you set up a pole on Earth and record the length of its shadow during the day, at some moment around twelve noon, the shadow will reach its shortest point; this moment is solar noon. If you are in a temperate zone and record the shadow length at noon every day, you will find that in a year: on a certain day in winter, the noon shadow is the longest; on a certain day in summer, the noon shadow is the shortest.

These are the definitions of "Winter Solstice" and "Summer Solstice." The interval between two Winter Solstices or two Summer Solstices is one year. Although humans on Earth cannot look down at the Earth's movement from space, by using such a simple method and measuring continuously for many years, we can know how many days it takes for the Earth to orbit the Sun once.

The ancient Chinese "Guibiao" (gnomon) was used to measure shadow length and thus define the "year." The length of a year we calculate is called a "tropical year."

However, it's not quite that simple; Earth's movement also has "precession" and "nutation." And this isn't anything new; it was noticed by ancient Greek astronomers as early as the second century BC. However, for this article, those details are a bit too complex.

= How to Define the Twenty-Four Solar Terms

We all know there are twenty-four solar terms. In the previous section, only the Winter Solstice and Summer Solstice were mentioned. Next is how to define the remaining twenty-two.

In the early years, the method was very simple and crude. Since the Winter Solstice had already been calculated through the "tropical year," dividing the time between two Winter Solstices into twenty-four equal intervals gave the twenty-four solar terms.

This method is called the "average solar term" method (Pingqi). It is actually quite rough, being simple division, but it was sufficient. This is because Earth's orbit is an ellipse very close to a circle, so Earth's orbital speed is roughly uniform.

The second method is more precise: after setting the Summer Solstice and Winter Solstice, a solar term is recorded for every 15 degrees the Earth moves along its orbital path. This requires precise astronomical observation and mathematical calculation, using some modern mathematics. This method is called the "fixed solar term" method (Dingqi) and began to be adopted in the late Ming Dynasty. It was developed with the assistance of foreign missionaries and based on Ptolemaic astronomy. According to Kepler's laws, we know that Earth's orbit is an ellipse and its speed is non-uniform, so the intervals between solar terms are not exactly the same.

Among the twenty-four solar terms, starting from the Winter Solstice or Summer Solstice, the first, third, fifth, seventh... terms are called "Zhongqi" (Major Terms). These include Summer Solstice, Major Heat, End of Heat, Autumnal Equinox, Frost Descent, Minor Snow, Winter Solstice, Major Cold, Rain Water, Vernal Equinox, Grain Rain, and Grain Full. You will find that in the Gregorian calendar, there are fixedly two solar terms every month, and the one at the end of the month is the "Zhongqi." This definition will be used later concerning leap months.

= Lunar Cycle

 The Moon's phase cycle is 29.5 days, but as mentioned earlier, this is not the Moon's orbital period. The Moon's orbital period is 27.3 days. The Moon reaches full moon when it moves to the side of the Earth facing away from the Sun, which is called "Wang"; when it moves to the side facing the Sun, the Moon cannot be seen, which is called "Shuo." As the saying goes, "things reach their extremes only to reverse," the time when the Moon is completely invisible does not last long, and soon a sliver of the crescent moon reappears, so the day of "Shuo" is also the day the new moon appears. In fact, in astronomy, "astronomical new moon" (Shuo) and "new moon" actually mean the same thing. This article may use these two terms interchangeably.

When the Moon orbits the Earth once, the Earth has also moved a certain distance around the Sun. Therefore, the Moon has to travel a bit further to reach the same position relative to the Sun. Thus, the Moon's phase cycle is one day longer than its orbital period.

According to the definition of the Lunar Calendar, the day of "Shuo" is the first day (Chuyi) of every month. Because the phase cycle is 29.5 days, each lunar month lasts between 29 and 30 days.

= Does Vietnam Celebrate the New Year on the Same Day as Us?

Vietnam also traditionally follows the Lunar Calendar, which is basically the same as the Chinese one. Therefore, when the Lunar New Year is called "Chinese New Year," there are some opposing voices on the Vietnamese internet, and many English media have changed it to "Lunar New Year" accordingly.

However, although both use the Lunar Calendar, Vietnam does not necessarily celebrate the New Year on the same day as us. Beijing's time zone is UTC+8, while Vietnam's time zone is UTC+7, a one-hour difference. Under special circumstances, relative to Beijing time, the astronomical new moon might occur after midnight, while relative to Hanoi time, it might occur before midnight. Thus, the first day of the first lunar month would be separated by one day. Therefore, although we and Vietnam adopt the same calendar, the dates of the traditional New Year are not necessarily the same.

= "Month of Zi," "Month of Chou," "Month of Yin"

The Earthly Branches start with "Zi, Chou, Yin, Mao." If you know a little bit about the "Four Pillars of Destiny" (Bazi), you will find that the first month of the lunar year corresponds not to "Zi," but to "Yin." The month corresponding to "Zi" is the eleventh month. This correspondence between months and Earthly Branches is also called "Yuejian" (monthly establishment). It is said that "Jian" refers to where the Big Dipper points; the eleventh month is the "Month of Zi" because the Big Dipper points to the "Zi" position.

I dislike this explanation; it's too metaphysical. "Month of Zi" has a more obvious and profound meaning, which is also a major feature of the Lunar Calendar as a lunisolar calendar: it is stipulated that the Winter Solstice must fall in the "Month of Zi." On the day of the Winter Solstice, it is exactly the day with the shortest daylight and longest night of the year. Correspondingly, "Zi Shi" among the twelve double-hours is also midnight. This wonderful resonance is much better than defining it using the mysterious Big Dipper.

During the Spring and Autumn and Warring States periods, which month to treat as the first month was controversial. Some places used Yin, some used Chou, and some used Zi. It is said that these three types of first months were the ones for the Xia, Yin, and Zhou dynasties, respectively, known as "Xia Zheng," "Yin Zheng," and "Zhou Zheng." But the authenticity of this claim is unverified. The Qin Dynasty used "Month of Hai," the month before the Winter Solstice, as the first month. However, during the reign of Emperor Wu of Han, "Xia Zheng" was finally established, making the "Month of Yin" the first month, and the "Month of Zi" accordingly became the eleventh month.

Since the Winter Solstice is in the eleventh month, the first astronomical new moon after the Winter Solstice is the first day of the twelfth month (La Yue), and the second astronomical new moon after the Winter Solstice is the first day of the first month, which is the Spring Festival.

So, if someone asks how the Spring Festival is determined, you can say with a bit of mystery, in the tone of an astrologer: "The second new moon after the Winter Solstice." However, this statement is not always accurate because of "leap months."

= Intercalation Rules (Leap Months)

Leap months are the most complex part of the Lunar Calendar. A tropical year is roughly 365.2422 days, while a synodic month is 29.5 days. If a year had 12 months, it would only have 29.5 × 12 = 354 days. Every two or three years, it would deviate from the tropical year by about a month. Therefore, when a deviation occurs, an extra month must be added to compensate. This is the leap month.

The intercalation rules of the Lunar Calendar can be divided into three stages:

The first stage is "seven leap months in nineteen years." This was the calendar used in the pre-Qin period. Based on observations of the synodic month cycle and the tropical year, there are roughly 7 leap months every 19 years. But this method is very rough.

After the Han Dynasty, the prevailing intercalation method was "leap month without Major Term" (Wu Zhongqi Zhi Run). As mentioned earlier, there are twelve "Zhongqi" distributed at intervals among the twenty-four solar terms. If the "average solar term" method (Pingqi) of dividing the tropical year into twenty-four equal parts is used, the interval between every two "Zhongqi" is 30.43 days. Over time, some months will appear that do not contain a "Zhongqi," and at this point, a leap month is inserted. This method balances the synodic month and the tropical year very well and is relatively easy to calculate, so it was implemented until the late Ming Dynasty.

In the third stage, in the *Chongzhen Calendar* of the late Ming dynasty, the Lunar Calendar underwent a major upgrade to become what it is today.

= The Modern Lunar Calendar

Reading the *Chongzhen Calendar* is a bit troublesome. Fortunately, the Purple Mountain Observatory participated in formulating a national standard for the Lunar Calendar in 2017, #link("https://openstd.samr.gov.cn/bzgk/gb/newGbInfo?hcno=E107EA4DE9725EDF819F33C60A44B296", ["Calculation and Promulgation of the Chinese Lunar Calendar (GB/T 33661-2017)"]), which precisely describes how leap months are intercalated.

- Beijing Time is used as the standard time.
- The day of the astronomical new moon is the first day of the lunar month.
- The lunar month containing the Winter Solstice is the eleventh month.
- If there are 13 lunar months between one eleventh month and the next (exclusive), then the first month that does not contain a "Zhongqi" is designated as the leap month.
- The second lunar month (not counting a leap month) after the eleventh month is the starting month of the lunar year.

Except for the first rule using "Beijing Time," which didn't exist in ancient times, all other rules are directly inherited from the *Chongzhen Calendar*.

Compared to previous calendars, the *Chongzhen Calendar* has two updates: first, the method for determining solar terms changed from "average solar term" to "fixed solar term." That is, from dividing a year into twenty-four parts to determining a solar term for every 15 degrees the Earth orbits the Sun. The fixed solar term method requires very precise measurement and complex calculation, and by the late Ming, Chinese astronomy had lagged behind Europe, requiring the help of missionaries to implement. Because Earth's orbit is elliptical, according to Kepler's laws, the orbital speed varies by season, so the number of days between solar terms changed dynamically from 14 to 16 days. Consequently, the intercalation rules also changed; because the Moon phase cycle is relatively stable while solar term intervals vary, more months appeared without a Major Term, and the simple "leap month without Major Term" rule could no longer be used alone, as it would result in too many leap months. Thus, the rule was modified to only add a leap month when there are 13 lunar months between two Winter Solstices.

Since then, in the Lunar Calendar, the year, month, and day are entirely determined by astronomical observation: solar terms are determined by the Earth's orbit, months are determined by the Moon's phase cycle, and the year is the result of both, calculated with intercalation rules. With the help of modern instruments, observations of the twenty-four solar terms, synodic months, and tropical years can be accurate to the second or even millisecond. Ironically, the current Gregorian calendar, because it lacks a mechanism for adjustment based on astronomical observation, will gradually accumulate error relative to the tropical year, deviating by one day every few thousand years.

= The 2033 Problem

Although the *Chongzhen Calendar* has been in effect for three hundred years, folk traditions often still stick to the old "leap month without Major Term" rule. In most years, these two are actually the same, but due to various subtle deviations, in 2033, the old rule and the modern intercalation rules will conflict. 2033 is quite special; this lunar year will have two months without a Major Term: the (original) eighth month and the (original) twelfth month. According to the old rule, the (original) eighth month would become a leap month after the seventh month, i.e., Leap Seventh Month. However, because there are only 12 lunar months between the eleventh month of 2032 and the eleventh month of 2033, while there are 13 months between the eleventh month of 2033 and the eleventh month of 2034, the leap month should be placed in the second month without a Major Term of that year: the twelfth month, making it a Leap Eleventh Month. Some folk "perpetual calendars" that do not adopt modern intercalation rules might be wrong here, which would cause the Mid-Autumn Festival to be off by a month.

At the same time, this is why the saying that the Lunar New Year is the "second new moon after the Winter Solstice" is inaccurate; if a Leap Eleventh Month or Leap Twelfth Month occurs, the New Year will become the third new moon after the Winter Solstice.

])
