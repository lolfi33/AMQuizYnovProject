import 'dart:math';

class ChestEnvelop {
  final String imageUrl;
  int nbExemplaire;

  ChestEnvelop({
    required this.imageUrl,
    required this.nbExemplaire,
  });
}

ChestEnvelop coffreCommun = ChestEnvelop(
  nbExemplaire: 0,
  imageUrl: 'assets/images/coffreCommun.png',
);

ChestEnvelop coffreRare = ChestEnvelop(
  nbExemplaire: 0,
  imageUrl: 'assets/images/coffreRare.png',
);

ChestEnvelop coffreLeg = ChestEnvelop(
  nbExemplaire: 0,
  imageUrl: 'assets/images/coffreLegendaire.png',
);

ChestEnvelop enveloppeCommune = ChestEnvelop(
  nbExemplaire: 0,
  imageUrl: 'assets/images/enveloppeCommune.webp',
);

ChestEnvelop enveloppeRare = ChestEnvelop(
  nbExemplaire: 0,
  imageUrl: 'assets/images/enveloppeRare.webp',
);

ChestEnvelop enveloppeLeg = ChestEnvelop(
  nbExemplaire: 0,
  imageUrl: 'assets/images/enveloppeLegendaire.webp',
);

var coffres = [
  ChestEnvelop(
    nbExemplaire: 0,
    imageUrl: 'assets/images/coffreCommun.png',
  ),
  ChestEnvelop(
    nbExemplaire: 0,
    imageUrl: 'assets/images/coffreRare.png',
  ),
  ChestEnvelop(
    nbExemplaire: 0,
    imageUrl: 'assets/images/coffreLegendaire.png',
  ),
];

var enveloppes = [
  ChestEnvelop(
    nbExemplaire: 0,
    imageUrl: 'assets/images/enveloppeCommune.webp',
  ),
  ChestEnvelop(
    nbExemplaire: 0,
    imageUrl: 'assets/images/enveloppeRare.webp',
  ),
  ChestEnvelop(
    nbExemplaire: 0,
    imageUrl: 'assets/images/enveloppeLegendaire.webp',
  ),
];

int randomCommun() {
  Random random = Random();
  int randomNumber = random.nextInt(100);

  if (randomNumber < 88) {
    return 1;
  } else if (randomNumber < 98) {
    return 2;
  } else {
    return 3;
  }
}

int randomRare() {
  Random random = Random();
  int randomNumber = random.nextInt(100);

  if (randomNumber < 88) {
    return 1;
  } else {
    return 3;
  }
}
