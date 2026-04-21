<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Drop existing CHECK constraint and recreate with futsal-specific types
        DB::statement('ALTER TABLE match_events DROP CONSTRAINT IF EXISTS match_events_type_check');
        DB::statement("
            ALTER TABLE match_events
            ADD CONSTRAINT match_events_type_check
            CHECK (type::text = ANY (ARRAY[
                'goal','own_goal','penalty_goal','penalty_miss',
                'yellow_card','red_card','second_yellow',
                'substitution','injury',
                'blue_card','foul','team_foul'
            ]::text[]))
        ");
    }

    public function down(): void
    {
        DB::statement('ALTER TABLE match_events DROP CONSTRAINT IF EXISTS match_events_type_check');
        DB::statement("
            ALTER TABLE match_events
            ADD CONSTRAINT match_events_type_check
            CHECK (type::text = ANY (ARRAY[
                'goal','own_goal','penalty_goal','penalty_miss',
                'yellow_card','red_card','second_yellow',
                'substitution','injury'
            ]::text[]))
        ");
    }
};
