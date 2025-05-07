<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Utilisateur;
use Illuminate\Support\Facades\Hash;

class HashUserPasswords extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'users:hash-passwords';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Hache les mots de passe des utilisateurs non sécurisés';

    /**
     * Execute the console command.
     *
     * @return void
     */
    public function handle()
    {
        $users = Utilisateur::all();

        foreach ($users as $user) {
            // Vérifier si le mot de passe est déjà hashé (bcrypt commence par '$2y$')
            if (!str_starts_with($user->password, '$2y$')) {
                $user->password = Hash::make($user->password);
                $user->save();
                $this->info("Le mot de passe de l'utilisateur {$user->email} a été haché.");
            }
        }

        $this->info('Traitement terminé.');
    }

}
