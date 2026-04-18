<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('match_days', function (Blueprint $table) {
            $table->id();
            $table->foreignId('season_id')->constrained()->cascadeOnDelete();
            $table->string('name'); // Jornada 1, Cuartos de final, etc.
            $table->integer('order')->default(0);
            $table->date('date')->nullable();
            $table->enum('type', ['group', 'round_of_16', 'quarter_final', 'semi_final', 'third_place', 'final'])->default('group');
            $table->timestamps();
        });

        Schema::create('matches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('season_id')->constrained()->cascadeOnDelete();
            $table->foreignId('match_day_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('home_team_id')->constrained('teams')->cascadeOnDelete();
            $table->foreignId('away_team_id')->constrained('teams')->cascadeOnDelete();
            $table->foreignId('referee_id')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('scheduled_at')->nullable();
            $table->string('venue')->nullable();
            $table->integer('home_score')->nullable();
            $table->integer('away_score')->nullable();
            $table->integer('home_penalty_score')->nullable();
            $table->integer('away_penalty_score')->nullable();
            $table->enum('status', ['scheduled', 'warmup', 'first_half', 'halftime', 'second_half', 'extra_time', 'penalties', 'finished', 'suspended', 'cancelled', 'postponed'])->default('scheduled');
            $table->text('observations')->nullable();
            $table->timestamps();
        });

        Schema::create('match_lineups', function (Blueprint $table) {
            $table->id();
            $table->foreignId('match_id')->constrained()->cascadeOnDelete();
            $table->foreignId('team_id')->constrained()->cascadeOnDelete();
            $table->foreignId('player_id')->constrained()->cascadeOnDelete();
            $table->integer('jersey_number')->nullable();
            $table->boolean('is_starter')->default(false);
            $table->string('position')->nullable();
            $table->timestamps();
            $table->unique(['match_id', 'player_id']);
        });

        Schema::create('match_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('match_id')->constrained()->cascadeOnDelete();
            $table->foreignId('team_id')->constrained()->cascadeOnDelete();
            $table->foreignId('player_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('secondary_player_id')->nullable()->constrained('players')->nullOnDelete();
            $table->enum('type', ['goal', 'own_goal', 'penalty_goal', 'penalty_miss', 'yellow_card', 'red_card', 'second_yellow', 'substitution', 'injury']);
            $table->integer('minute');
            $table->string('half')->nullable(); // first, second, extra_first, extra_second
            $table->text('notes')->nullable();
            $table->timestamps();
        });

        Schema::create('standings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('season_id')->constrained()->cascadeOnDelete();
            $table->foreignId('group_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('team_id')->constrained()->cascadeOnDelete();
            $table->integer('played')->default(0);
            $table->integer('won')->default(0);
            $table->integer('drawn')->default(0);
            $table->integer('lost')->default(0);
            $table->integer('goals_for')->default(0);
            $table->integer('goals_against')->default(0);
            $table->integer('goal_difference')->default(0);
            $table->integer('points')->default(0);
            $table->integer('position')->default(0);
            $table->json('form')->nullable(); // ['W','W','L','D','W']
            $table->timestamps();
            $table->unique(['season_id', 'group_id', 'team_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('standings');
        Schema::dropIfExists('match_events');
        Schema::dropIfExists('match_lineups');
        Schema::dropIfExists('matches');
        Schema::dropIfExists('match_days');
    }
};
