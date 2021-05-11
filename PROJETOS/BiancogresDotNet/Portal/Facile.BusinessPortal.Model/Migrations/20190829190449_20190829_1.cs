using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20190829_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Origem",
                table: "Antecipacao",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Status",
                table: "Antecipacao",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "AntecipacaoHistorico",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    AntecipcaoID = table.Column<long>(nullable: false),
                    TituloPagarID = table.Column<long>(nullable: true),
                    UsuarioID = table.Column<long>(nullable: false),
                    DataEvento = table.Column<DateTime>(nullable: false),
                    Observacao = table.Column<string>(nullable: true),
                    Status = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AntecipacaoHistorico", x => x.ID);
                    table.ForeignKey(
                        name: "FK_AntecipacaoHistorico_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AntecipacaoHistorico_Antecipacao_TituloPagarID",
                        column: x => x.TituloPagarID,
                        principalTable: "Antecipacao",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AntecipacaoHistorico_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AntecipacaoHistorico_Usuario_UsuarioID",
                        column: x => x.UsuarioID,
                        principalTable: "Usuario",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AntecipacaoHistorico_EmpresaID",
                table: "AntecipacaoHistorico",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_AntecipacaoHistorico_TituloPagarID",
                table: "AntecipacaoHistorico",
                column: "TituloPagarID");

            migrationBuilder.CreateIndex(
                name: "IX_AntecipacaoHistorico_UnidadeID",
                table: "AntecipacaoHistorico",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_AntecipacaoHistorico_UsuarioID",
                table: "AntecipacaoHistorico",
                column: "UsuarioID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AntecipacaoHistorico");

            migrationBuilder.DropColumn(
                name: "Origem",
                table: "Antecipacao");

            migrationBuilder.DropColumn(
                name: "Status",
                table: "Antecipacao");
        }
    }
}
