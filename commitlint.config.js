const Configuration = {
    rules: {
        'body-leading-blank': [1, 'always'],
        'body-max-line-length': [2, 'always', 100],
        'body-case': [1, 'always', 'lower-case'],
        'footer-leading-blank': [1, 'always'],
        'footer-max-line-length': [2, 'always', 100],
        'header-max-length': [2, 'always', 100],
        'subject-case': [2, 'never', ['sentence-case', 'start-case', 'pascal-case', 'upper-case'],],
        'subject-empty': [2, 'never'],
        'subject-full-stop': [2, 'never', '.'],
        'scope-case': [1, 'always', 'kebab-case'],
        'type-case': [2, 'always', 'lower-case'],
        'type-empty': [2, 'never'],
        'type-enum': [2, "always", ['add', 'remove', 'update', 'fix', 'chore']]
    },
    defaultIgnores: true,
    helpUrl:
        'https://github.com/conventional-changelog/commitlint/#what-is-commitlint',
};

module.exports = Configuration;
