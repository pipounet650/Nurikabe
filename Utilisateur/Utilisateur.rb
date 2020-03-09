class Utilisateur
  private_class_method :new
  attr_reader :nom 
  attr_accessor :credit, :utilisateur
 
  def Utilisateur.Creer(nom)
    new(nom)
  end

  def initialize(nom)
    Dir.chdir("/home/linux/Documents/Nurikabe/Utilisateur")
    fichier = File.open("#{nom}",'a+')
    @utilisateur = Array.new

    if !File.zero?(fichier)
      @utilisateur = Marshal.load(fichier)
      @nom = @utilisateur[0]
      @credit = @utilisateur[1]
    else
      @utilisateur[0] = nom
      @utilisateur[1] = 0
      Marshal.dump(utilisateur, fichier)
    end
    fichier.close
  end

  def self.verifNom(nom)
    return File.exist?(nom)
  end

  def self.supprimerUtilisateur(nom)
    File.delete(nom)
  end

  def self.comptesUtilisateurs()
    Dir.chdir("/home/linux/Documents/Nurikabe/Utilisateur")
    print Dir.glob("*[^.rb]").sort
  end

  def changerCredit(montant)
    Dir.chdir("/home/linux/Documents/Nurikabe/Utilisateur")
    fichier = File.open("#{self.nom}",'a+')

    @utilisateur[0] = self.nom
    @utilisateur[1] = self.credit += montant

    Marshal.dump(utilisateur, fichier)
    fichier.close
  end

# WAIT CLASSEMENT
  def tempsMoyen()
    @niveauTermine = 0
    for n in (0..Grille.lenght)
      if(@nom == Grille.utilisateur)
        tempsMoyen += Grille.temps
        @niveauTermine += 1
      end
    end
    return @tempsMoyen/@niveauTermine
  end

  def to_s()
    "Pseudo : #{self.nom}Crédit :#{self.credit}\n"
  end

end
