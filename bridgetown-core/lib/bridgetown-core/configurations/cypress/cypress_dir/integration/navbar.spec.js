describe("Testing that links exist in the navbar", () => {
  beforeEach(() => {
    cy.visit("/");
  });
  it("navbar links appear on all pages", () => {
    const baseUrl = Cypress.config("baseUrl");

    cy.get('[href="/"]').click();
    cy.url().should("eq", baseUrl + "/");

    cy.get('[href="/posts"]').click();
    cy.url().should("eq", baseUrl + "/posts/");

    cy.get('[href="/about"]').click();
    cy.url().should("eq", baseUrl + "/about/");
  });
});
