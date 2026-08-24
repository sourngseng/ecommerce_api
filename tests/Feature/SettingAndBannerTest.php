<?php

namespace Tests\Feature;

use App\Models\Banner;
use App\Models\Setting;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SettingAndBannerTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_retrieve_public_general_settings(): void
    {
        Setting::set('site_title', 'Cambodia E-Commerce');
        Setting::set('site_logo', 'https://example.com/logo.png');

        $response = $this->getJson('/api/v1/settings');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'site_title' => 'Cambodia E-Commerce',
                    'site_logo' => 'https://example.com/logo.png',
                ],
            ]);
    }

    public function test_admin_can_update_settings(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);

        $response = $this->actingAs($admin)->putJson('/api/v1/admin/settings', [
            'settings' => [
                ['key' => 'site_title', 'value' => 'New Title', 'group' => 'general'],
                ['key' => 'site_logo', 'value' => 'https://example.com/new-logo.png', 'group' => 'general'],
                ['key' => 'site_favicon', 'value' => 'https://example.com/favicon.ico', 'group' => 'general'],
            ],
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'site_title' => 'New Title',
                    'site_logo' => 'https://example.com/new-logo.png',
                    'site_favicon' => 'https://example.com/favicon.ico',
                ],
            ]);

        $this->assertEquals('New Title', Setting::get('site_title'));
    }

    public function test_can_retrieve_active_banners(): void
    {
        Banner::create([
            'title' => 'Slider 1',
            'image_url' => 'https://example.com/slider1.jpg',
            'position' => 'slider',
            'status' => 'active',
        ]);

        Banner::create([
            'title' => 'Inactive Banner',
            'image_url' => 'https://example.com/inactive.jpg',
            'position' => 'slider',
            'status' => 'inactive',
        ]);

        $response = $this->getJson('/api/v1/banners?position=slider');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ]);

        $data = $response->json('data');
        $this->assertCount(1, $data);
        $this->assertEquals('Slider 1', $data[0]['title']);
    }

    public function test_admin_can_create_and_manage_banners(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);

        $createResponse = $this->actingAs($admin)->postJson('/api/v1/admin/banners', [
            'title' => 'Hero Banner Promo',
            'subtitle' => 'Exclusive discounts',
            'image_url' => 'https://example.com/hero.jpg',
            'position' => 'hero_banner',
            'status' => 'active',
        ]);

        $createResponse->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'title' => 'Hero Banner Promo',
                    'position' => 'hero_banner',
                ],
            ]);

        $bannerId = $createResponse->json('data.id');

        // Update
        $updateResponse = $this->actingAs($admin)->putJson("/api/v1/admin/banners/{$bannerId}", [
            'title' => 'Updated Hero Banner',
        ]);

        $updateResponse->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'title' => 'Updated Hero Banner',
                ],
            ]);

        // Delete
        $deleteResponse = $this->actingAs($admin)->deleteJson("/api/v1/admin/banners/{$bannerId}");
        $deleteResponse->assertStatus(200);

        $this->assertDatabaseMissing('banners', ['id' => $bannerId]);
    }

    public function test_admin_can_upload_logo_asset(): void
    {
        \Illuminate\Support\Facades\Storage::fake('public');
        $admin = User::factory()->create(['role' => 'admin']);

        $file = \Illuminate\Http\UploadedFile::fake()->image('custom-logo.png', 300, 100);

        $response = $this->actingAs($admin)->postJson('/api/v1/admin/settings/upload', [
            'file' => $file,
            'type' => 'logo',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'type' => 'logo',
                ],
            ]);

        $this->assertNotEmpty(Setting::get('site_logo'));
    }
}
