using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201201_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "ItemContaID",
                table: "SubItemConta",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.CreateIndex(
                name: "IX_SubItemConta_ItemContaID",
                table: "SubItemConta",
                column: "ItemContaID");

            migrationBuilder.AddForeignKey(
                name: "FK_SubItemConta_ItemConta_ItemContaID",
                table: "SubItemConta",
                column: "ItemContaID",
                principalTable: "ItemConta",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SubItemConta_ItemConta_ItemContaID",
                table: "SubItemConta");

            migrationBuilder.DropIndex(
                name: "IX_SubItemConta_ItemContaID",
                table: "SubItemConta");

            migrationBuilder.DropColumn(
                name: "ItemContaID",
                table: "SubItemConta");
        }
    }
}
