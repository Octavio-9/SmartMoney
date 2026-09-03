<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable(['code', 'name_fr', 'currency', 'currency_name', 'flag_code', 'dial_code'])]
class Country extends Model
{
    public function operators(): HasMany
    {
        return $this->hasMany(Operator::class, 'country_code', 'code');
    }
}
