# encoding: utf-8

module CommonLanguages

  #
  # Language data, sorted by number of native speakers
  # https://en.wikipedia.org/wiki/List_of_languages_by_number_of_native_speakers
  #
  # fields: code, name, english name, right to left?
  #
  DATA = [
    ['zh', '中文', 'Chinese'],
    ['es', 'Español', 'Spanish'],
    ['en', 'English'],
    ['hi', 'हिन्दी', 'Hindi'],
    ['ar', 'العربية', 'Arabic', true],
    ['pt', 'Português', 'Portugues'],
    ['bn', 'বাংলা', 'Bengali'],
    ['ru', 'Pyccĸий', 'Russian'],
    ['ja', '日本語', 'Japanese'],
    ['pa', 'ਪੰਜਾਬੀ', 'Punjabi'],
    ['de', 'Deutsch', 'German'],
    ['ms', 'بهاس ملايو', 'Malay'],
    ['te', 'తెలుగు', 'Telugu'],
    ['vi', 'Tiếng Việt', 'Vietnamese'],
    ['ko', '한국어', 'Korean'],
    ['fr', 'Français', 'French'],
    ['mr', 'मराठी', 'Marathi'],
    ['ta', 'தமிழ்', 'Tamil'],
    ['ur', 'اُردُو', 'Urdu'],
    ['fa', 'فارسی', 'Farsi'],
    ['tr', 'Türkçe', 'Turkish'],
    ['it', 'Italiano', 'Italian'],
    ['th', 'ภาษาไทย', 'Thai'],
    ['gu', 'Gujarati'],
    ['pl', 'Polski', 'Polish'],
    ['ml', 'Malayalam'],
    ['uk', 'Ukrainian'],
    ['sw', 'Swahili'],
    ['uz', 'Uzbek'],
    ['ro', 'Romanian'],
    ['nl', 'Nederlands', 'Dutch'],
    ['sr', 'Serbian'],
    ['el', 'Ελληνικά', 'Greek'],
    ['ca', 'Català', 'Catalan'],
    ['he', 'עברית', 'Hebrew', true]
  ]

  # just the codes, in sorted order
  def self.codes
    @codes ||= DATA.map {|d| d[0]}
  end

  # a regexp that will match the possible codes
  def self.match
    @match ||= /(#{@codes.join('|')})/
  end

  # map of codes to Language objects
  # e.g. languages['en'] => <Language>
  def self.languages
    @languages ||= Hash[
      DATA.map {|data|
        [data[0], Language.new(data)]
      }
    ]
  end

end

#
# TO BE ADDED
#
# [:bn, 'Bengali']
# [:bo, 'Tibetan']
# [:bg, 'Bulgarian']
# [:ca, 'Catalan']
# [:cs, 'Czech']
# [:cy, 'Welsh']
# [:da, 'Danish']
# [:et, 'Estonian']
# [:eu, 'Basque']
# [:fj, 'Fijian']
# [:fi, 'Finnish']
# [:ga, 'Irish']
# [:hr, 'Croatian']
# [:hu, 'Hungarian']
# [:hy, 'Armenian']
# [:id, 'Indonesian']
# [:is, 'Icelandic']
# [:ka, 'Georgian']
# [:km, 'Central Khmer']
# [:lv, 'Latvian']
# [:lt, 'Lithuanian']
# [:mr, 'Marathi']
# [:mk, 'Macedonian']
# [:mt, 'Maltese']
# [:mn, 'Mongolian']
# [:mi, 'Maori']
# [:ms, 'Malay']
# [:ne, 'Nepali']
# [:no, 'Norwegian']
# [:pa, 'Panjabi']
# [:qu, 'Quechua']
# [:sk, 'Slovak']
# [:sl, 'Slovenian']
# [:sm, 'Samoan']
# [:sq, 'Albanian']
# [:sv, 'Swedish']
# [:ta, 'Tamil']
# [:tt, 'Tatar']
# [:te, 'Telugu']
# [:to, 'Tonga']
# [:tr, 'Turkish']
# [:ur, 'Urdu']
# [:xh, 'Xhosa']
