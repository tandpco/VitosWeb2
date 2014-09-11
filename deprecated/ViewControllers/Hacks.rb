class Hacks
  public
  def self.specialtyImages(spec)
    assoc = {
      5     => "Supreme300x300.jpg",
      6     => "TheWorks300x300.jpg",
      7     => "PepperoniPleas300x300.jpg",
      8     => "CHEESEBURGER3000x300.jpg",
      9     => "Hawaiian3000x300.jpg",
      10    => "Taco3000x300.jpg",
      11    => "Veggie300x300.jpg",
      12    => "BLT3000x300.jpg",
      13    => "BBQ3000x300.jpg",
      14    => "Mediterranean3000x300.jpg",
      16    => "ChickenBaconRanch3000x300.jpg",
      19    => "ChickenChipotle3000x300.jpg",
      22    => "TheWorks300x300.jpg",
      94    => "TonyPackos300x300.jpg",
      27    => "ItalianFoldoverSub300x300.jpg",
      28    => "ItalianFoldoverSub300x300.jpg",
      29    => "ItalianFoldoverSub300x300.jpg",
      30    => "ItalianFoldoverSub300x300.jpg",
      32    => "ItalianFoldoverSub300x300.jpg",
      33    => "ItalianFoldoverSub300x300.jpg",
      36    => "ItalianFoldoverSub300x300.jpg",
      37    => "ItalianFoldoverSub300x300.jpg",
      44    => "ItalianFoldoverSub300x300.jpg",
      45    => "ItalianFoldoverSub300x300.jpg",
      38    => "ChickenSalad3000x300.jpg",
      39    => "ItalianSalad3000x300.jpg",
      40    => "ItalianSalad3000x300.jpg",
      41    => "ItalianSalad3000x300.jpg",
      42    => "ItalianSalad3000x300.jpg",
      8002  => "VitoBread300x300.jpg",
      8004  => "ChickenWings300x300.jpg",
      8005  => "CinnamonBread300x300.jpg",
      8007  => "ChickenDippers300x300.jpg",
      8015  => "CokeEtc300x300.jpg"
    }

    puts('specialtyImages'+spec.to_s,assoc[spec])
    return assoc[spec].blank? ? assoc[5] : assoc[spec];
  end

end