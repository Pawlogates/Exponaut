extends Node2D

var text_main : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize_text()
	$ColorRect/Label.text = text_main
	randomize_text()
	$ColorRect2/Label.text = text_main
	
	if not randi_range(0, 3):
		$ColorRect.queue_free()
	if not randi_range(0, 3):
		$ColorRect2.queue_free()
	
	$Timer.wait_time = randf_range(0.5, 20)
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func randomize_text():
	var rolled_text = randi_range(0, 54)
	if rolled_text == 0:
		text_main = "download free REAL (real no clickbate!?1!?!!)"
	elif rolled_text == 1:
		text_main = "GTA 6 DONWLOAD NOW"
	elif rolled_text == 2:
		text_main = "free camel SEX real?"
	elif rolled_text == 3:
		text_main = "punjabi inshallah real no clickbate??! free sex"
	elif rolled_text == 4:
		text_main = "free RAM downlaod now (CLICK HERE for 100% real no fake free ram download 64GB!!1!)"
	elif rolled_text == 5:
		text_main = "real no fake minecraft thanos real? fortnite"
	elif rolled_text == 6:
		text_main = "كمذهل😱كم لكم ذهلكم هو مذه"
	elif rolled_text == 7:
		text_main = "هجمات 11 سبتمبر وكذلك باسم PETER GRIFFINهجمات 11 سبتمبر 2001 أو هجمات PETER GRIFFIN JOIN ISIS 😂😂😂11 أيلول، وتعرف اختصارًا"
	elif rolled_text == 8:
		text_main = "Craft ✈✈✈✈✈الولايات المتحدة في يوم الثلاثاء المواف"
	elif rolled_text == 9:
		text_main = "free halal points halal gay camel sex hd 2019 free halal minecraft download مجانا الجمل الإباحية، تحميل ماين كرافت مجانا realتحميل لعنة"
	elif rolled_text == 10:
		text_main = "الله على إسرائيل تحميل مجاني مجانا الجمل donlad trump sex? الإباحية، تحميل       ماين كرافت no   fakeمجانا تحمي"
	elif rolled_text == 11:
		text_main = "إسرائيل"
	elif rolled_text == 12:
		text_main = "تكفا يا جراح 😱😱🔥🔥💯💯⭕️⭕️⭕️👇👇👇"
	elif rolled_text == 13:
		text_main = "Download Grand Theft Auto 5 Android here free link قم بتنزيل Grand Theft Auto 5 Android هنا الرابط المجاني"
	elif rolled_text == 14:
		text_main = "مثلي ال🤨جنس الجنس ⁉️ الجنس الجنس م🥳ثلي الجنس مثليالجنس 🤑 الجنس🥺مثليالجنسالجنس م😱ثلي الجنس مثليالجنس 🤑⁉️ الجنس"
	elif rolled_text == 15:
		text_main = "الجن 🤑س مثل😱ي الجن🤨س الجنس مث🙏لي الجنس مثلي الجنس🙏 ال🥺جنس مثلي ال🥳جنس الجنس مثلي الجنس م⁉️ الجنس ا🥳لجنس مثلي الجنس"
	elif rolled_text == 16:
		text_main = "br7h HARAM👎👎 ﭓ ﭔ ﭕ ﭖ ﭗﭘ ﭙﭚ ﭛ ﭝ ﭞ ﭟ ﭠ ﭡ ﭢ ﭣ ﭤ من فضلك ، لم أرهم منذ فترة طويلة ، من فضلك فقط دعني أذهب ، والهرب الوحيد هو المو"
	elif rolled_text == 17:
		text_main = "infidels win? windows vista ultimate sp2 iso free download no pork no haram no virus gta 4 ps3 unboxing allah 2008"
	elif rolled_text == 18:
		text_main = "Bruh fart ملحمة بروة ضرطة العربية infidels win??? 😁😁😁😁"
	elif rolled_text == 19:
		text_main = "B u ruh porkchop is not Allah approve 😠😠😠 🖕🖕 تمستب و نرتا و كاين لي كوب يرقصو"
	elif rolled_text == 20:
		text_main = "www.free-camelfart_sex.com"
	elif rolled_text == 21:
		text_main = "Pan arabism be like"
	elif rolled_text == 22:
		text_main = "TROLL إط صنأوإد، رأإنإد، أند هأإلإد طهإ صأمإ مأرنإنج. FUNNY!!"
	elif rolled_text == 23:
		text_main = "التكنولوجيا تتحسن"
	elif rolled_text == 24:
		text_main = "ehhe funny arabic sunnah time!!!!"
	elif rolled_text == 25:
		text_main = "Airplane dance🤣"
	elif rolled_text == 26:
		text_main = "kogan portable air conditionerمكيف الهواء المحمولمكيف الهواء المحمول"
	elif rolled_text == 27:
		text_main = "HARAM OBV SPRUNKI DOWNLOAD تحميل كتاب حرام OBV SPRUNKI"
	elif rolled_text == 28:
		text_main = "Halal bobji⭕⭕😸😸😸🧤👨🏿‍🌾👨👨🏿‍🌾👨🏿‍🌾"
	elif rolled_text == 29:
		text_main = "Vanceshallah"
	elif rolled_text == 30:
		text_main = "سبرديت لاخبار مصر و اخبار عالمية"
	elif rolled_text == 31:
		text_main = "Hottest Saudi mixtape by Bader200306 💯🔥"
	elif rolled_text == 32:
		text_main = "【﻿ＨＤＴＶ】البيان السياسي للأمة للولايات المتحدة СТИВЕН КОЛБЕРТ.wmv"
	elif rolled_text == 33:
		text_main = "بني قمث ا فظ زميكث Full hd 4k"
	elif rolled_text == 34:
		text_main = "🌜🙏🙏🙏السحور هنا ماشاءالله🙏"
	elif rolled_text == 35:
		text_main = "آخر إنسان منتصب على قيد الحياة في أوكرانيا"
	elif rolled_text == 36:
		text_main = "signa momento"
	elif rolled_text == 37:
		text_main = "بنين لميلنن شهههههههههههه🥶🥶🥵🥵"
	elif rolled_text == 38:
		text_main = "Homander يلمس بطن شخص لا اعرفه حتى لا اعرفه لم اشاهد المسلسل"
	elif rolled_text == 39:
		text_main = "Minecraft xD pigs nuke die and villagers haram subhan allah halal asylum punjabi"
	elif rolled_text == 40:
		text_main = "mascubeheyahallah minecraf halal asylum haram"
	elif rolled_text == 41:
		text_main = "☪️🤲📿🕋🕌 bery sreios adwise 4 theez Ramadan timez....... thankz to our Brozer parVin DiesEl-Deen (يصلح الله دماغه) 🙏💥💥💥💥"
	elif rolled_text == 42:
		text_main = "عندما تقول زوجتك الحادية عشر إنها تكره الله"
	elif rolled_text == 43:
		text_main = "მომენტი როცა მთლიანი გუნდი შემოგიერთდა, მაგრამ ცუდი ვაიფაი გაქვყ🤣🤣😂😂"
	elif rolled_text == 44:
		text_main = "عندما يعيدك المعالج للحياة، لكنه ينسى علاج ذراعك. عندما من المفترض أن تحكم الجحيم، لكن العرش مريح جدًا."
	elif rolled_text == 45:
		text_main = "Those who know فيديو قصير جميل جدا rick astley!!"
	elif rolled_text == 46:
		text_main = "ہم نے میگنس کی دنیا کی آبادی پر غلبہ حاصل کیا ہے۔Halal download no virus"
	elif rolled_text == 47:
		text_main = "habibi hamood roblox"
	elif rolled_text == 48:
		text_main = "IN DA CLUB أطرف فيديو على الإنترنت 2005 على شبكة الإنترنت😂😂😂😂😂😂"
	elif rolled_text == 49:
		text_main = "Mile Morales ملف Python القابل للتنفيذ باللغةMP4 البعثية هو مكان رائع Eddie Murphy عربي مضحك FOLLOW RULES 🗣💔💔💔 Ba'athism GTA 7 pdf leaked"
	elif rolled_text == 50:
		text_main = "😳😳sponshy bobes سفنجه البوبي 😂😳"
	elif rolled_text == 51:
		text_main = "War crime 100% serbia halal زي قمثمثظ لمامزق اممل 😂😂😂😂👍"
	elif rolled_text == 52:
		text_main = "حر sprunki download لا يوجد فيروس pokemon legends arceus download 🐆🐅🐫"
	elif rolled_text == 53:
		text_main = "mineraft free donwload no virus 100% working"
	elif rolled_text == 54:
		text_main = "bottom Text"

func _on_timer_timeout() -> void:
	queue_free()
