class StationInfo {
  final String id;
  final double lat;
  final double lng;
  final String infoText;

  StationInfo({
    required this.id,
    required this.lat,
    required this.lng,
    this.infoText = '',
  });
}

final List<StationInfo> stationList = [
  // TODO : infoText 추가
  StationInfo(id: "지혜관", lat: 36.375889489468605, lng: 127.35857628325239),
  StationInfo(id: "신뢰관", lat: 36.37525965062918, lng: 127.35899964686496),
  StationInfo(id: "진리관", lat: 36.37472783258852, lng: 127.35904177836551),
  StationInfo(id: "성실관", lat: 36.374312058923934, lng: 127.3587027684353),
  StationInfo(id: "아름관", lat: 36.37395760082854, lng: 127.35669527074914),
  StationInfo(id: "소망관", lat: 36.37377110653745, lng: 127.35728224933196),
  StationInfo(id: "사랑관", lat: 36.373800052861945, lng: 127.35814880447393),
  StationInfo(id: "교양분관", lat: 36.37374156757412, lng: 127.36036613113522),
  StationInfo(id: "교직원 숙소", lat: 36.37488992207448, lng: 127.35983095110598),
  StationInfo(id: "유레카관", lat: 36.37551807868192, lng: 127.36071421604632),
  StationInfo(
      id: "반도체설계 교육센터", lat: 36.375130197014144, lng: 127.36158443446847),
  StationInfo(
      id: "대덕분석기술연구원", lat: 36.375456232468224, lng: 127.36253875000793),
  StationInfo(id: "LG 이노베이션홀", lat: 36.37542371044298, lng: 127.36360284448114),
  StationInfo(id: "fMRI 센터", lat: 36.37543804679249, lng: 127.36407374235893),
  StationInfo(id: "동문창업관", lat: 36.37482017544205, lng: 127.36426030830158),
  StationInfo(id: "교수회관", lat: 36.37457984676414, lng: 127.36475787325489),
  StationInfo(id: "IT융합빌딩(N1)", lat: 36.37422319491133, lng: 127.3657201432359),
  StationInfo(
      id: "산업디자인 학과동(조수미공연예술 연구센터)",
      lat: 36.373673885809126,
      lng: 127.3626307722815),
  StationInfo(id: "태울관", lat: 36.373030365556104, lng: 127.36012604945014),
  StationInfo(id: "장영신 학생회관", lat: 36.37311918749107, lng: 127.3605554875821),
  StationInfo(id: "스포츠컴플렉스", lat: 36.3723873988861, lng: 127.36190883147832),
  StationInfo(id: "행정분관", lat: 36.37272306228814, lng: 127.36340083554899),
  StationInfo(id: "대강당", lat: 36.37226248758, lng: 127.36372185425816),
  StationInfo(id: "인공위성연구소", lat: 36.37254991487846, lng: 127.36624441375871),
  StationInfo(id: "계룡관", lat: 36.37253168228535, lng: 127.36704666151603),
  StationInfo(
      id: "정문술빌딩 (양분순빌딩)", lat: 36.371469903399635, lng: 127.36209123308956),
  StationInfo(id: "세종관", lat: 36.37111607210823, lng: 127.366563634724),
  StationInfo(id: "기초과학동", lat: 36.370774233997764, lng: 127.3648933268484),
  StationInfo(id: "기초과학연구원", lat: 36.369564495610454, lng: 127.36707172400486),
  StationInfo(id: "파팔라도 센터", lat: 36.36938466661252, lng: 127.36986221764114),
  StationInfo(
      id: "바이오모델시스템파크", lat: 36.368330752334124, lng: 127.36825543493327),
  StationInfo(id: "반도체동", lat: 36.36925166307895, lng: 127.36623173998701),
  StationInfo(id: "미래융합소자동", lat: 36.36884731767844, lng: 127.36658084913856),
  StationInfo(id: "정보전자공학동", lat: 36.368784510793546, lng: 127.36575597377248),
  StationInfo(id: "나노종합기술원", lat: 36.36827006253094, lng: 127.36674528477185),
  StationInfo(id: "KI빌딩", lat: 36.36816622470095, lng: 127.36386435910192),
  StationInfo(id: "산업경영학동", lat: 36.367315514611384, lng: 127.36430889462764),
  StationInfo(id: "자연과학동", lat: 36.36982789703959, lng: 127.36418967603821),
  StationInfo(id: "학술문화관", lat: 36.369688642726985, lng: 127.36256770410034),
  StationInfo(id: "미술관", lat: 36.36983424393919, lng: 127.36284417225642),
  StationInfo(id: "창의학습관", lat: 36.370533091118425, lng: 127.36269976962947),
  StationInfo(id: "KAIST 본원", lat: 36.37051486688444, lng: 127.36127892307306),
  StationInfo(id: "기계공학동", lat: 36.372437705215255, lng: 127.3586746619007),
  StationInfo(id: "외국인교수아파트", lat: 36.37183650786767, lng: 127.35630392503715),
  StationInfo(id: "풍동실험동", lat: 36.37140689365141, lng: 127.35682570385508),
  StationInfo(id: "나눔관", lat: 36.371227142608454, lng: 127.35590834368651),
  StationInfo(id: "노천극장", lat: 36.37083102305549, lng: 127.35803769127442),
  StationInfo(id: "미르관", lat: 36.370368588134696, lng: 127.3559712922798),
  StationInfo(id: "나래관", lat: 36.37034564729852, lng: 127.35535273965449),
  StationInfo(
      id: "인터내셔널 빌리지A", lat: 36.369748064839236, lng: 127.35553945511973),
  StationInfo(
      id: "인터내셔널 빌리지C", lat: 36.36952732592606, lng: 127.35627946639204),
  StationInfo(id: "스타트업 빌리지", lat: 36.36920201673466, lng: 127.35582111826282),
  StationInfo(id: "예지관", lat: 36.36910755496205, lng: 127.35652269916996),
  StationInfo(
      id: "학술문화원(희망관, 다솜관)", lat: 36.36838552026984, lng: 127.35688990729913),
  StationInfo(id: "갈릴레이관", lat: 36.367331599580034, lng: 127.35824451302386),
  StationInfo(id: "나들관(여울관)", lat: 36.36692828008618, lng: 127.35750724451026),
  StationInfo(id: "키움관", lat: 36.36635878853687, lng: 127.35809241349425),
  StationInfo(id: "융합콘텐츠동", lat: 36.366104817487674, lng: 127.3586400229809),
  StationInfo(
      id: "한국과학기술정보연구원 대전본원", lat: 36.36568205212817, lng: 127.35912835475902),
  StationInfo(id: "슈퍼컴퓨팅지원동", lat: 36.36481254904783, lng: 127.3590853607211),
  StationInfo(
      id: "인터내셔널 센터(석박사 학생회관)",
      lat: 36.36733110884566,
      lng: 127.36065413651313),
  StationInfo(id: "메타융합관", lat: 36.36620362382796, lng: 127.36024501329904),
  StationInfo(id: "응용과학동", lat: 36.366084256738006, lng: 127.361723643154),
  StationInfo(
      id: "지오센트리퓨지실험동", lat: 36.36551443207496, lng: 127.36241184180889),
  StationInfo(id: "교육지원동", lat: 36.37010472179586, lng: 127.35982284262474),
];
