require 'gtk3'
require_relative 'GGrille.rb'
require_relative 'BoutonRetour.rb'

module Gui
    
    ##
    # Interface de jeu contenant une GGrille.
    class InterfaceJeu < Gtk::Box
        
        ## Barre de titre associée à l'interface de jeu.
        attr_reader :titlebar
        
        ## Historique de la grille
        attr_reader :historique
        
        ##
        # Crée une interface de jeu pour la grille donnée.
        #
        # Paramètres :
        # [+app+]       Nurikabe
        # [+grille+]    GrilleJouable
        def initialize(app, grille)
            super(:vertical)
            
            gg = GGrille.new(grille, app.utilisateur)
            self.pack_start(gg)
            @historique = gg.historique
            
            @titlebar = Gtk::HeaderBar.new.tap { |barre|
                barre.title = "Nurikabe"
                barre.subtitle = "Niveau #{grille.solution.numero}"
                barre.show_close_button = true
                barre.pack_start(BoutonRetour.new.tap { |bouton|
                    bouton.signal_connect("clicked") {
                        case grille.solution.mode
                        when "Aventure" then app.aventure
                        when "Arcade" then app.aventure
                        else app.accueil
                        end
                    }
                })
                annuler = Gtk::Button.new(icon_name: 'edit-undo-symbolic')
                refaire = Gtk::Button.new(icon_name: 'edit-redo-symbolic')
                barre.pack_start(annuler.tap { |annuler|
                    annuler.signal_connect("clicked") {
                        @historique.precedent { |element|
                            grille.grille.grille[element.case_jeu.ligne
                                ][element.case_jeu.colonne].etatCase =
                                element.etat_avant
                        }
                        gg.update
                    }
                    annuler.sensitive = !@historique.debut?
                    annuler.show
                })
                barre.pack_start(refaire.tap { |refaire|
                    refaire.signal_connect("clicked") {
                        @historique.suivant { |element|
                            grille.grille.grille[element.case_jeu.ligne
                                ][element.case_jeu.colonne].etatCase =
                                element.etat_apres
                        }
                        gg.update
                    }
                    refaire.sensitive = !@historique.fin?
                    refaire.show
                })
                barre.pack_end(Gtk::MenuButton.new.tap { |bouton|
                    bouton.image = Gtk::Image.new(
                        icon_name: 'open-menu-symbolic')
                    bouton.show
                })
                verifier = Gtk::Button.new(icon_name: 'checkmark')
                barre.pack_end(verifier.tap { |verifier|
                    verifier.show
                })
                aide_btn = Gtk::Button.new(label: "Aide",
                                           icon_name: 'help-contextual')
                barre.pack_end(aide_btn.tap { |bouton|
                    bouton.show
                })
                
                boite_terminee_affichee = false
                gg.on_update {
                    grille.verifErreur
                    if(grille.grilleTerminee?) then
                        gg.desactiver
                        annuler.sensitive = false
                        refaire.sensitive = false
                        aide_btn.sensitive = false
                        verifier.sensitive = false
                        unless(boite_terminee_affichee) then
                            Gtk::MessageDialog.new(
                                title: "Gagné",
                                parent: app.fenetre,
                                flags: Gtk::DialogFlags::USE_HEADER_BAR |
                                Gtk::DialogFlags::MODAL |
                                Gtk::DialogFlags::DESTROY_WITH_PARENT,
                                message: "Vous avez terminé la grille"
                            ).tap { |boite|
                                boite.signal_connect("response") {
                                    boite.close
                                }
                                boite.show
                            }
                            boite_terminee_affichee = true
                        end
                    else
                        annuler.sensitive = !@historique.debut?
                        refaire.sensitive = !@historique.fin?
                    end
                }
                
                
                barre.show
            }
            
            @historique.replay { |element|
                grille.grille.grille[element.case_jeu.ligne
                    ][element.case_jeu.colonne].etatCase = element.etat_apres
            }
            gg.update
            
            self.show
        end
        
    end
    
end